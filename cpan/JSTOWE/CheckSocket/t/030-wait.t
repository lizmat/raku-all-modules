use v6;
use Test;

plan 1;

use CheckSocket;

my $port = 50000;

# yes it is stupid using the thing being tested to prepare the test
# but this is the least fallible way of doing this
while check-socket($port) {
    $port++;
}

start {
    sleep 3;
    my $socket = IO::Socket::INET.new(localhost => 'localhost', localport => $port, listen => True);
    loop {
        my $client = $socket.accept;
    }
}

# 

ok(wait-socket($port), "wait-socket - port $port default localhost");

# vim: expandtab shiftwidth=4 ft=perl6
