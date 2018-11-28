use v6;
use Test;

use LWP::Simple;

plan 1;

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

my $html = LWP::Simple.get('http://eu.httpbin.org/html');

ok(
    $html.match('Herman'),
    'homepage is downloaded and has "Herman" in it'
);


