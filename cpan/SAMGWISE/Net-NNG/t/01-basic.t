#! /usr/bin/env perl6
use v6.c;
use Test;
use Net::NNG;

use-ok 'Net::NNG';
use Net::NNG;
use Net::NNG::Options;

ok (my $rep-socket = nng-rep0-open).&report-fail, "Create NNG rep0 socket";
ok (my $req-socket = nng-req0-open).&report-fail, "Create NNG req0 socket";

# set timeouts
ok nng-setopt($_, NNG_OPT_RECVTIMEO, 1000, :ms), "Set receive timeout limit" for $rep-socket, $req-socket;

# Ensure the ids have been set
ok $rep-socket.id != $req-socket.id, "Socket ids are different";

my $url = 'tcp://127.0.0.1:8889';
ok nng-listen($rep-socket, $url).&report-fail, "Start listening on rep socket";
ok nng-dial($req-socket, $url).&report-fail, "Dial on req socket";

# Send receive test
my $server = start {
    CATCH { warn "Encountered error in server thread: { .gist }" }
    my $message = nng-recv($rep-socket);
    nng-send
        $rep-socket,
        $message
            .decode('utf8')
            .flip
            .encode('utf8')
}

my $message = "Testing, testing, 1, 2, 3";
nng-send($req-socket, $message.flip.encode('utf8'));
my $response = nng-recv($req-socket).decode('utf8');

is $response, $message, "Request/Response round trip";

# Clean up
ok nng-close($rep-socket).&report-fail, "Close rep socket";
ok nng-close($req-socket).&report-fail, "Close req socket";

done-testing;

#! report a failure if present and pass on the result of .so
sub report-fail($r --> Bool) {
    $*ERR.say: $r.gist if $r ~~ Failure;
    $r.so
}
