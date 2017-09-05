#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;

say "tsting multipart message splitting and reception";

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

say  "Sending and receiving a multipart text message on paired socket" ;

use-ok  'Net::ZMQ::Socket' , 'Module Socket can load';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Error;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;


my $ctx = Context.new(:throw-everything);
my $s1 = Socket.new($ctx, :pair, :throw-everything);
my $s2 = Socket.new($ctx, :pair, :throw-everything);

my $uri = 'inproc://con';
$s1.bind($uri);
$s2.connect($uri);


my ($p1, $p2) = ('Héllo ', 'Wörld');
my  ($l1, $l2) = ($p1.chars, $p2.chars);
my $p = "$p1$p2"; 
my $l = $l1 + $l2;

my buf8 $buf = buf8.new( | $p.encode('ISO-8859-1'));
ok $s1.send( $buf , 30 , :split) == $l,  "sent part 1 $l  bytes: $p" ;

my $rcvd1 = $s2.receive;
say "$rcvd1 received";
ok $p eq $rcvd1, "full message sent in one part and received correctly {($p, $rcvd1).perl  }";
ok $s2.incomplete == 0 , "multipart flag received unset";

ok $s1.send(:split, $buf, 6) == $l,  "sent in parts total  $l  bytes: $p" ;

$rcvd1 = $s2.receive;
say "$rcvd1 received";
my $rs = $p.substr(0,6) ;
ok $rs eq $rcvd1, "part 1 of  message sreceived correctly {($rs, $rcvd1).perl  }";
ok $s2.incomplete == 1 , "multipart flag received set";

$rcvd1 = $s2.receive;
say "$rcvd1 received";
$rs = $p.substr(6,6) ;
ok $rs eq $rcvd1, "part 2 of  message received correctly {($rs, $rcvd1).perl  }";
ok $s2.incomplete == 0 , "multipart flag received unset";

my $p3 = "tomorrow the föx wìll comê to town, ho ho ho ho!";
my $l3 = $s2.send($p3, 5, :split);
ok $l3 == $p3.chars , "sent $l3: --$p3--";
my $rcf = $s1.receive :slurp;
ok $rcf eq $p3, "received --$rcf-- passed" ;
ok $s1.incomplete == 0 , "multipart flag received unset";

$s2.disconnect.close;
$s1.unbind.close;

done-testing;

