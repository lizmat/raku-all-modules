use v6;

use Smack::Middleware;

unit class Smack::Middleware::Head is Smack::Middleware;

method call(%env) {
    $.app.(%env).then(sub ($p) {
        return $p unless %env<REQUEST_METHOD> eq 'HEAD';
        my $res = $p.result;
        $res[0], $res[1], [];
    });
}
