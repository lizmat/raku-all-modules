#!/usr/bin/env perl6

use Net::ZMQ;
use Net::ZMQ::Constants;

my Net::ZMQ::Context $ctx .= new;
my Net::ZMQ::Socket $sock .= new($ctx, ZMQ_PULL);
$sock.bind("tcp://127.0.0.1:2910");

loop {
    say "# Receiving...";
    my $msg = $sock.receive(0);
    last if not $msg;
    say "`{$msg.data}'";
}

# vim: ft=perl6
