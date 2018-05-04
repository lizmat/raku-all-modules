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
has Callable %!exception_handlers    = ();
has Callable %!halt_handlers{Int}    = ();
has Hematite::Route %!routes_by_name = ();
has %.config                         = ();
has Log $.log;

has Hematite::Handler $!handler;
has Lock $!lock;

subset Helper where .signature ~~ :($ctx, |args);
has Helper %!helpers = ();

method new(*%args) {
    return self.bless(|%args);
}

submethod BUILD(*%args) {
    %!config         = %args;
    $!lock           = Lock.new;

    # get the 'main' log that could be defined anywhere
    $!log = Log.get;

    # error/exception default handler
    self.error-handler(sub ($ctx, *%args) {
        my Exception $ex = %args{'exception'};
        my $body         = sprintf("%s\n%s", get_http_status_msg(500), $ex.gist);

        $ctx.halt(
            status  => 500,
            body    => $body,
            headers => {
                'Content-Type' => 'text/plain',
            },
        );

        # log exception
        $ctx.log.error($ex.gist);

        return;
    });

    # halt default handler
    self.error-handler(X::Hematite::HaltException, sub ($ctx, *%args) {
        my Int $status = %args<status>;
        my %headers    = %(%args<headers>);
        my $body       = %args<body> || get_http_status_msg($status);

        my Hematite::Response $res = $ctx.response;

        my Bool $inline = $body.isa(Str) ?? True !! False;

        my %render_options = (
            inline => $inline,
            status => $status,
        );

        if (!(%args<body>:exists)) {
            %render_options<format> = 'text';
        }

        # render
        $ctx.render($body, |%render_options,);

        # set headers
        $res.field(|%headers);

        return;
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

multi method error-handler(Exception:U $type) returns Callable {
    return %!exception_handlers{$type.^name};
}

multi method error-handler(Exception:U $type, Callable $fn) returns ::?CLASS {
    %!exception_handlers{$type.^name} = $fn;
    return self;
}

multi method error-handler() {
    return self.error-handler(Exception);
}

multi method error-handler(Callable $fn) {
    return self.error-handler(Exception, $fn);
}

multi method error-handler(Int $status) returns Callable {
    return %!halt_handlers{$status};
}

multi method error-handler(Int $status, Callable $fn) returns ::?CLASS {
    %!halt_handlers{$status} = $fn;
    return self;
}

method get-route(Str $name) returns Hematite::Route {
    return %!routes_by_name{$name};
}

multi method helper(Str $name, Helper $fn) {
    %!helpers{$name} = $fn;
    return self;
}

multi method helper(Str $name) {
    return %!helpers{$name};
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
