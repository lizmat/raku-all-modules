use v6;

use Smack::Middleware;

unit class Smack::Middleware::XFramework is Smack::Middleware;

use Smack::Util;

has Str $.framework is required;

method call(%env) {
    callsame() then-with-response -> $s, @h, $e {
        Smack::Util::header-set(@h, X-Framework => $.framework);
        Nil;
    }
}
