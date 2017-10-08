#!/usr/bin/env perl6

use Net::ZMQ4;
use Net::ZMQ4::Constants;

my Net::ZMQ4::Context $ctx .= new;
my Net::ZMQ4::Socket $sock .= new($ctx, ZMQ_PULL);
$sock.bind("tcp://127.0.0.1:2910");

loop {
    say "# Receiving...";
    my $msg = $sock.receive(0);
    last if $msg.data-str eq '';
    say $msg.data-str;
}
