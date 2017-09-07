#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;
use NativeCall;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;


say  "Test Proxy";

#plan ;

use-ok 'Net::ZMQ::Proxy' , "Proxy Module loads ";

use Net::ZMQ::Common;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;
use Net::ZMQ::Proxy;

my $ctx = Context.new(:throw-everything);

my $f = Socket.new($ctx, :router, :throw-everything);
my $b = Socket.new($ctx, :dealer, :throw-everything);
#my $cpt = Socket.new($ctx, :, :throw-everything);
my $ctl = Socket.new($ctx, :pull, :throw-everything);


my $uri = 'tcp://127.0.0.1:45000';
$f.bind($uri);
my $uri2 = 'tcp://127.0.0.1:45001';
$b.bind($uri2);
my $uri3 = 'tcp://127.0.0.1:45002';


$ctl.connect($uri3);

my $p = start { 
  my $ctx2 = Context.new(:throw-everything);
  my $my = Socket.new($ctx2, :push, :throw-everything);
  $my.bind($uri3);
  sleep 4; 
  $my.send('TERMINATE' );
  $my.unbind.close;
} 

sleep 1;
my $r =  Proxy.new( :frontend($f)
            , :backend($b)
#            , :capture(False)
            , :control($ctl)
#            );
    ).run;

await $p;

#my $rc = $ctl.receive :slurp;
#say $rc;
ok $r == 0 , "proxy terminated cleanly";

;
$f.unbind.close;
$b.unbind.close;

$ctl.disconnect.close;


done-testing;
