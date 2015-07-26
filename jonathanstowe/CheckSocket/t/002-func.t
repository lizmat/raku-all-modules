use v6;
use lib 'lib';
use Test;

plan 6;

use CheckSocket;

my $port = 50000;

# yes it is stupid using the thing being tested to prepare the test
# but this is the least fallible way of doing this
while check-socket($port) {
    $port++;
}

ok(!check-socket($port), "check-socket - port $port default localhost");
ok(!check-socket($port, 'localhost'), "check-socket - port $port");
ok(!check-socket($port, '127.0.0.1'), "check-socket - port $port numeric IP");
diag "start server on port 5000";

my $p = Promise.new;


start {
    my $socket = IO::Socket::INET.new(localhost => 'localhost', localport => $port, listen => True);
    $p.keep;
    loop {
        my $client = $socket.accept;
    }
}

my $p2 = $p.then({
            ok(check-socket($port), "check-socket - port $port default localhost");
            ok(check-socket($port, 'localhost'), "check-socket - port $port");
            ok(check-socket($port, '127.0.0.1'), "check-socket - port $port numeric IP");
            exit 0;
            True;
});

await $p2;

# vim: expandtab shiftwidth=4 ft=perl6
