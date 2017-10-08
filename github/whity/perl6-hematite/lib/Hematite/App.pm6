use HTTP::Status;
use Cookie::Baker;
use JSON::Fast;
use Log;
use X::Hematite;
use Hematite::Context;
use Hematite::Router;
use Hematite::Response;
use Hematite::Templates;
use Hematite::Handler;

unit class Hematite::App is Hematite::Router does Callable;

has Callable %!render_handlers       = ();
has Callable %!error_handlers        = ();
has Hematite::Route %!routes_by_name = ();
has %.config                         = ();
has Log $.log;

has Hematite::Handler $!handler;
has Lock $!lock;

method new(*%args) {
    return self.bless(|%args);
}

submethod BUILD(*%args) {
    %!config = %args;

    $!lock = Lock.new;

    # get the 'main' log that could be defined anywhere
    $!log = Log.get;

    # default handler
    self.error-handler('unexpected', sub ($ctx, *%args) {
        my Exception $ex = %args{'exception'};
        my Int $status   = 500;

        $ctx.response.set-code($status);
        $ctx.response.field(Content-Type => 'text/plain');
        $ctx.response.content =
            sprintf("%s\n%s", get_http_status_msg($status), $ex.gist);

        # log exception
        $ctx.log.error($ex.gist);

        return;
    });

    # halt default handler
    self.error-handler('halt', sub ($ctx, *%args) {
        my Int $status = %args{"status"};
        my %headers    = %(%args{"headers"});
        my Str $body   = %args{"body"} || get_http_status_msg($status);

        my Hematite::Response $res = $ctx.response;

        # set status code
        $res.set-code($status);

        # set headers
        $res.field(|%headers);

        # set content
        $res.content = $body;
    });

    # default render handlers

    self.render-handler('template', Hematite::Templates.new(|(%args{'templates'} || {})));
    self.render-handler('json', sub ($data, *%args) { return to-json($data); });

    return self;
}

method CALL-ME(Hash $env) returns List {
    return self._handler.($env);
}

multi method render-handler(Str $name) returns Callable {
    return %!render_handlers{$name};
}

multi method render-handler(Str $name, Callable $fn) {
    %!render_handlers{$name} = $fn;
    return self;
}

multi method error-handler(Str $name) returns Callable {
    return %!error_handlers{$name};
}

multi method error-handler(Str $name, Callable $fn) returns ::?CLASS {
    %!error_handlers{$name} = $fn;
    return self;
}

multi method error-handler() {
    return self.error-handler('unexpected');
}

multi method error-handler(Int $status) {
    return self.error-handler(~($status));
}

multi method error-handler(Callable $fn) {
    return self.error-handler('unexpected', $fn);
}

multi method error-handler(Int $status, Callable $fn) {
    return self.error-handler(~($status), $fn);
}

method get-route(Str $name) returns Hematite::Route {
    return %!routes_by_name{$name};
}

method _handler() returns Callable {
    $!lock.protect({
        if (!$!handler) {
            # prepare routes
            self.log.debug('preparing routes...');
            my @routes = self._prepare-routes;
            for @routes -> $route {
                if ($route.name) {
                    %!routes_by_name{$route.name} = $route;
                }
            }

            # prepare main middleware
            self.log.debug('preparing middleware...');
            self.use(sub ($ctx) {
                for @routes -> $route {
                    if ($route.match($ctx)) {
                        $route($ctx);
                        return;
                    }
                }

                $ctx.not-found;
            });
            my Callable $stack = self._prepare-middleware(self.middlewares);

            $!handler = Hematite::Handler.new(app => self, stack => $stack);
        }
    });

    return $!handler;
}

method _prepare-routes() returns Array {
    my @routes = self.routes;

    # sub-routers
    for self.groups.kv -> $pattern, $router {
        my @group_routes = $router._prepare-routes($pattern, []);
        @routes.append(@group_routes);
    }

    # sort routes
    @routes .= sort({ $^a.pattern cmp $^b.pattern });

    return @routes;
}
