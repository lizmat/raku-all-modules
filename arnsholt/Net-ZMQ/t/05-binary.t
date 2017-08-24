use v6;

use Test;
use Net::ZMQ4;
use Net::ZMQ4::Constants;

plan 6;

my Net::ZMQ4::Context $ctx .= new();

pass 'creating context';

my Net::ZMQ4::Socket $alice .= new($ctx, ZMQ_PAIR); #Net::ZMQ::Constants::ZMQ_PAIR);
pass 'creating socket - imported constant';
my Net::ZMQ4::Socket $bob .= new($ctx, Net::ZMQ4::Constants::ZMQ_PAIR); #Net::ZMQ::Constants::ZMQ_PAIR);
pass 'creating socket - namespaced constant';

$alice.setopt(ZMQ_SNDHWM, 10);
$alice.setopt(ZMQ_RCVHWM, 10);
$bob.setopt(ZMQ_SNDHWM, 10);
$bob.setopt(ZMQ_RCVHWM, 10);

$alice.bind('inproc://alice');
pass 'binding to inproc address';
$bob.connect('inproc://alice');
pass 'connecting to inproc address';

my $buf = buf8.new(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
$alice.send($buf, 0);
ok $bob.receive(0).data() eqv $buf, 'sending and receiving simple binary message';

$alice.close;
$bob.close;
$ctx.term;

done-testing;
