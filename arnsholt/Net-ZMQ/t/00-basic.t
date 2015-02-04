use v6;

use Test;

use Net::ZMQ;
use Net::ZMQ::Constants;

plan 10;

my Net::ZMQ::Context $ctx .= new();
pass 'creating context';

my Net::ZMQ::Socket $alice .= new($ctx, ZMQ_PAIR); #Net::ZMQ::Constants::ZMQ_PAIR);
pass 'creating socket - imported constant';
my Net::ZMQ::Socket $bob .= new($ctx, Net::ZMQ::Constants::ZMQ_PAIR); #Net::ZMQ::Constants::ZMQ_PAIR);
pass 'creating socket - namespaced constant';

$alice.bind('inproc://alice');
pass 'binding to inproc address';
$bob.connect('inproc://alice');
pass 'connecting to inproc address';

$alice.send('foo', 0);
is $bob.receive(0).data-str(), 'foo', 'sending and receiving simple message';


$alice.send('quux', ZMQ_SNDMORE);
pass 'sending SNDMORE message';
$alice.send('barf', 0);

is $bob.receive(0).data-str(), 'quux', 'receiving first part of two-part message';
is $bob.getopt(ZMQ_RCVMORE), 1, 'getting RCVMORE flag';
is $bob.receive(0).data-str(), 'barf', 'receiving second part of two-parter';

# vim: ft=perl6
