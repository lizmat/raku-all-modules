use v6;
use Test;

use LWP::Simple;

plan 1;

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

# don't use rakudo.org anymore, it has proven to be rather unreliable :(
my $logo = LWP::Simple.get('http://http.perl6.org/camelia-logo.png');

ok(
    $logo.bytes == 57601 && $logo[ 57_600 ] == 130,
    'Fetched Camelia Logo'
);

