#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;

say "tsting get/set scket options";

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

say  "Sending and receiving a multipart text message on paired socket" ;

use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Error;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;


my $ctx = Context.new:throw-everything;
my $s1 = Socket.new($ctx, :pair, :throw-everything);
my $s2 = Socket.new($ctx, :pair, :throw-everything);

my $uri = 'inproc://con';
$s1.bind($uri);
$s2.connect($uri);


my ($p1, $p2) = ('Héllo ', 'Wörld');
my  ($l1, $l2) = ($p1.encode('UTF-8').bytes, $p2.encode('UTF-8').bytes);

ok $s1.send($p1, :part) == $l1,  "sent part 1 $l1  bytes: $p1" ;
ok $s1.send($p2) == $l2,  "sent part2 $l2  bytes: $p2" ;

my $rcvd1 = $s2.receive;
say "$rcvd1 received";
ok $p1 eq $rcvd1, "part 1 of message sent and received correctly {($p1, $rcvd1).perl  }";
ok $s2.incomplete == 1 , "multipart flag received";
my $rcvd2  = $s2.receive;
say "$rcvd2 received";
ok $p2 eq $rcvd2, "part 2 of message sent and received correctly {($p2, $rcvd2).perl  }";

$s2.disconnect.close;
$s1.unbind.close;

done-testing;

