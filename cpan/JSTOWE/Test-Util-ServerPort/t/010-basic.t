#!perl6

use v6;

use Test;

use Test::Util::ServerPort;
ok True, "got as far as loading it";

lives-ok {
    ok my $port = get-unused-port(), "got a port";
    ok $port ~~ any(1025 .. 65535), "and it's in the right range";
    my $s = IO::Socket::INET.new(:listen, localport => $port);
    ok $s.defined, "got a socket";
    $s.close;
    ok $port = get-unused-port(42000 .. 42500), "get port in a smaller range";
    ok $port ~~ any(42000 .. 42500), "and it's in the right range";
    $s = IO::Socket::INET.new(:listen, localport => $port);
    ok $s.defined, "got a socket";
    $s.close;

}, "and nothing died";





done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
