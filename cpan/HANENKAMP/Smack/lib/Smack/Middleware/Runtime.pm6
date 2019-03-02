use v6;

use Smack::Middleware;

unit class Smack::Middleware::Runtime is Smack::Middleware;

use Smack::Util;

has Str $.header-name = 'X-Runtime';

method call(%env) {
    my $start = now;
    callsame() then-with-response -> $s, @h, $e {
        my $req-time = (now - $start).fmt("%.6f");
        Smack::Util::header-set(@h, $.header-name => $req-time);
        Nil;
    }
}
