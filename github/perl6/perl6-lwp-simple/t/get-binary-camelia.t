use v6;
use Test;

use LWP::Simple;

plan 1;

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

my $logo = LWP::Simple.get('http://eu.httpbin.org/image/png');

say $logo.bytes ~ " " ~ $logo[333];
ok(
    $logo.bytes == 8090 && $logo[ 333 ] == 68,
    'Fetched Camelia Logo'
);

