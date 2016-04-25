#!perl6

use v6;

use Test;
use CheckSocket;
use Audio::Icecast;

my $host        = %*ENV<ICECAST_TEST_HOST> // 'localhost';
my $port        = (%*ENV<ICECAST_TEST_PORT> // 8000).Int;
my $user        = %*ENV<ICECAST_TEST_USER> // 'admin';
my $password    = %*ENV<ICECAST_TEST_PASS> // 'hackme';

if check-socket($port, $host) {
    pass "got an icecast server";
    my $obj;
    lives-ok { $obj = Audio::Icecast.new(:$host, :$port, :$user, :$password) }, "get object with full credentials";
    my $stats;
    lives-ok { $stats = $obj.stats }, "get stats";
    isa-ok $stats, Audio::Icecast::Stats, "and it indeed is the right object";
}
else {
    skip "no icecast server - won't test";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
