use v6;

use Test;

use Net::ZMQ4;
use Net::ZMQ4::Constants;

plan 13;

my Net::ZMQ4::Context $ctx .= new();
pass 'creating context';

my Net::ZMQ4::Socket $alice .= new($ctx, ZMQ_PAIR);
pass 'creating socket - imported constant';
my Net::ZMQ4::Socket $bob .= new($ctx, Net::ZMQ4::Constants::ZMQ_PAIR);
pass 'creating socket - namespaced constant';

$alice.bind('inproc://alice');
pass 'binding to inproc address';
$bob.connect('inproc://alice');
pass 'connecting to inproc address';

$alice.send('foo', 0);
ok my $msg = $bob.receive(0), "receive the data";
is $msg.data-str(), 'foo', 'sending and receiving simple message';
$msg.close;

$alice.send('quux', ZMQ_SNDMORE);
pass 'sending SNDMORE message';
$alice.send('barf', 0);

ok $msg =  $bob.receive(0), "get the message";
is $msg.data-str(), 'quux', 'receiving first part of two-part message';
$msg.close;
is $bob.getopt(ZMQ_RCVMORE), 1, 'getting RCVMORE flag';
ok $msg =  $bob.receive(0), "get the second part of the message";
is $msg.data-str(), 'barf', 'receiving second part of two-parter';
$msg.close;

$alice.close;
$bob.close;
$ctx.term;
