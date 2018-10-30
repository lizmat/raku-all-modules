use v6;

use Test;
use Net::ZMQ4;
use Net::ZMQ4::Constants;

my Net::ZMQ4::Context $ctx .= new();

my $alice = Net::ZMQ4::Socket.new($ctx, ZMQ_PUSH);
$alice.bind('inproc://alice');
my $bob = Net::ZMQ4::Socket.new($ctx, ZMQ_PULL);
$bob.connect('inproc://alice');

$alice.sendmore('My', 'First', 'Message');

my $res = $bob.receivemore;

ok $res[0] eqv Buf[uint8].new(77,121), 'Part 1';
ok $res[1] eqv Buf[uint8].new(70,105,114,115,116), 'Part 2';
ok $res[2] eqv Buf[uint8].new(77,101,115,115,97,103,101), 'Part 3';

$alice.close;
$bob.close;
$ctx.term;

done-testing;
