#!/usr/bin/env perl6

use Net::ZMQ4;
use Net::ZMQ4::Constants;

my Net::ZMQ4::Context $ctx .= new;
my Net::ZMQ4::Socket $sock .= new($ctx, ZMQ_PUSH);
$sock.connect("tcp://127.0.0.1:2910");

loop {
    print "Message: ";
    my $msg = $*IN.get;
    my int $flag = 0;
    $sock.send($msg, $flag);
    last if not $msg;
}
