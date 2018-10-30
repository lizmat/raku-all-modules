use v6.c;

use URI;

class TestURIRequire {
    method test(Str $uri) {
        my $u = URI.new($uri);
        $u.port;
    }
}
