use v6;

use Smack::Middlware;

unit class Smack::Middleware::HTTP11 does Smack::Middleware;

# Adds connection persistence ala HTTP/1.1 to an HTTP/1.0 server
method call(%env) {
    # Do nothing if the server is already HTTP/1.1 (or something else)
    return $.app.(%env) if %env<SERVER_PROTOCOL> ne 'HTTP/1.0';
}
