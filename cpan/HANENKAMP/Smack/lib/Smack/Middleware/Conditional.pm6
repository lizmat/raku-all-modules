use v6;

use Smack::Middleware;

unit class Smack::Middleware::Conditional is Smack::Middleware;

has Mu $.condition is required;
has &!middleware;
has &.builder is required;

method configure(%config) {
    # Configure the app first
    callsame();

    # Then setup and configure the middleware
    &!middleware = &.builder.(&.app);
    &!middleware = &!middleware.(%config)
        if &!middleware.returns ~~ Callable;
}

method call(%env) {
    my &app = %env ~~ $.condition ?? &!middleware !! &.app;
    app(%env);
}
