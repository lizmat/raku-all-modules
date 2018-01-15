use X::Hematite;
use Hematite::Route;
use Hematite::Context;

unit class Hematite::Router;

has Callable @!middlewares    = ();
has Hematite::Router %!groups = ();
has Hematite::Route @!routes  = ();

method new() {
    return self.bless();
}

# fallback for the http method
method FALLBACK($name where /^<[A .. Z]>+$/, |args) {
    return self.METHOD($name, |@(args));
}

method middlewares() returns Array {
    my @copy = @!middlewares;
    return @copy;
}

method routes() returns Array {
    return @!routes.clone;
}

method groups() returns Hash {
    return %!groups.clone;
}

multi method use(Callable:D $middleware) returns ::?CLASS {
    @!middlewares.push($middleware);
    return self;
}

multi method use(Callable:U $middleware, *%options) returns ::?CLASS {
    @!middlewares.push($middleware.new(|%options));
    return self;
}

method group(Str $pattern is copy) returns ::?CLASS {
    if ($pattern.substr(0, 1) ne "/") {
        $pattern = "/" ~ $pattern;
    }
    $pattern ~~ s/\/$//; # remove ending slash

    my Hematite::Router $group = %!groups{$pattern};
    if (!$group) {
        $group = %!groups{$pattern} = Hematite::Router.new;
    }

    return $group;
}

multi method METHOD(Str $method, Str $pattern, Callable $fn) returns Hematite::Route {
    return self!create-route($method, $pattern, self!middleware-runner($fn));
}

multi method METHOD(Str $method, Str $pattern, @middlewares is copy, Callable $fn) returns Hematite::Route {
    # prepare middleware
    my Callable $stack = self._prepare-middleware(@middlewares, $fn);

    # create route
    return self!create-route($method, $pattern, $stack);
}

method !create-route(Str $method, Str $pattern is copy, Callable $fn) returns Hematite::Route {
    # add initial slash to pattern
    if ($pattern.substr(0, 1) ne "/") {
        $pattern = "/" ~ $pattern;
    }

    my Hematite::Route $route = Hematite::Route.new($method.uc, $pattern, $fn);
    @!routes.push($route);

    return $route;
}

method _prepare-routes(Str $parent_pattern, @middlewares is copy) returns Array {
    my @routes = [];

    @middlewares.append(@!middlewares);

    # create routes with the router middleware
    for @!routes -> $route {
        my $stack = self._prepare-middleware(@middlewares, $route.stack);
        @routes.push(
            Hematite::Route.new(
                $route.method,
                $parent_pattern ~ $route.pattern,
                $stack
            )
        );
    }

    # sub-routers
    for %!groups.kv -> $pattern is copy, $router {
        $pattern = $parent_pattern ~ $pattern;
        my @group_routes = $router._prepare-routes($pattern, @middlewares);
        @routes.append(@group_routes);
    }

    return @routes;
}

method _prepare-middleware(@middlewares, Callable $app?) returns Callable {
    my Callable $stack = $app;
    for @middlewares.reverse -> $mdw {
        $stack = self!middleware-runner($mdw, $stack);
    }

    return $stack;
}

method !middleware-runner(Callable $mdw, Callable $next?) returns Block {
    my Callable $tmp_next = $next || sub {};

    return sub (Hematite::Context $ctx) {
        try {
            my Int $arity = Nil;
            if ($mdw.isa(Code)) {
                $arity = $mdw.arity;
            }
            else {
                my ($method) = $mdw.can('CALL-ME');
                $arity = $method.arity - 1;
            }

            given $arity {
                when 2 { $mdw($ctx, $tmp_next); }
                when 1 { $mdw($ctx); }
                default { $mdw(); }
            }

            # catch http exceptions and detach
            CATCH {
                my $ex = $_;

                when X::Hematite::DetachException {
                    # don't do nothing, stop current middleware process
                }
            }
        }
    };
}
