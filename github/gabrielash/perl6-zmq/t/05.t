#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

say  "Sending and receiving simple text on paired socket" ;

use-ok  'Net::ZMQ::Socket' , 'Module Socket can load';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Error;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;


say "testing PAIRed sockets"; 

my $ctx = Context.new(:throw-everything);
my $s1 = Socket.new($ctx, :pair, :throw-everything);
my $s2 = Socket.new($ctx, :pair, :throw-everything);

pass "Sockets created ...pass";

my $uri = 'inproc://con';

lives-ok  {$s1.bind($uri)}, 's1 binds succesfully' ;
lives-ok  {$s2.connect($uri)}, 's2 connects succesfully' ;;

my Str $sent = "Héllo";
my int $len = $sent.encode('UTF-8').bytes;
ok $s1.send($sent) == $len,  "sent $len  bytes: $sent" ;
my $rcvd  = $s2.receive;
say "$rcvd received";
ok $sent eq $rcvd, "message sent and received correctly {($sent, $rcvd).perl  }";

ok $s1.send($sent) == $len,  "sent $len  bytes: $sent" ;
$rcvd  = $s2.receive;
say "$rcvd received";
ok $sent eq $rcvd, "message sent and received correctly {($sent, $rcvd).perl  }";

my $num = 778_459;
ok $s1.send($num) == 6 ,  "sent 8  bytes (int): $num" ;
my Int $rcvdi  = $s2.receive :int;
say "$rcvdi received";
ok $num eq $rcvdi, "message sent and received correctly {($num, $rcvdi).perl  }";

$num = -1;
ok $s1.send($num) == 2 ,  "sent 8  bytes (int): $num" ;
$rcvdi  = $s2.receive :int;
say "$rcvdi received";
ok $num eq $rcvdi, "message sent and received correctly {($num, $rcvdi).perl  }";

lives-ok { $s2.disconnect }, "disconnct S2 pass" ;
lives-ok { $s1.unbind }, "unbind $s1 pass" ;

$s1.close();
$s2.close();
pass "closing sockets pass";


done-testing;
