#!/usr/bin/env perl6

use Net::ZMQ;
use Net::ZMQ::Constants;

my Net::ZMQ::Context $ctx .= new;
my Net::ZMQ::Socket $sock .= new($ctx, ZMQ_PUSH);
$sock.connect("tcp://127.0.0.1:2910");

loop {
    print "Message: ";
    my $msg = $*IN.get;
    my int $flag = 0;
    $sock.send($msg, $flag);
    last if not $msg;
}

# vim: ft=perl6
