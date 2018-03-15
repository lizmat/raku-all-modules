use v6;
use Test;

use LWP::Simple;

plan 15;

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

# test getstore under http
skip 'issue #25 rakudo.org is moving to https', 5;
# need to find another site or withdraw http tests
##getstore-tests('http://www.rakudo.org', rx/Rakudo/);

try require IO::Socket::SSL;
if $! {
    skip-rest("IO::Socket::SSL not available");
    exit 0;
}

getstore-tests('https://www.opera.com', rx/Opera \s+ browser/);
# Note: http://www.opera.com redirects to https
getstore-tests('http://www.opera.com', rx/Opera \s+ browser/);

sub getstore-tests($url, $rx) {
    my $fname = $*SPEC.catdir($*TMPDIR, "./tmp-getstore-$*PID");
    try unlink $fname;

    ok(
        LWP::Simple.getstore($url, $fname),
        'getstore() returned success'
       );

    my $fh = open($fname);
    ok($fh, 'Opened file handle written by getstore()');

    ok $fh.slurp-rest ~~ $rx, 'Found pattern in downloaded file';

    ok($fh.close, 'Close the temporary file');

    ok(unlink($fname), 'Delete the temporary file');
}
