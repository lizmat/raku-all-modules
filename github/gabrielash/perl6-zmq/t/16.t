#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;
use NativeCall;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;


say  "Test EchoServer";

#plan ;

use-ok 'Net::ZMQ::EchoServer' , "Proxy Module loads ";

use Net::ZMQ::Common;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;
use Net::ZMQ::EchoServer;


my $ctx = Context.new(:throw-everything);

my Socket $c = Socket.new($ctx, :client, :throw-everything);
my $uri = 'tcp://127.0.0.1:45002';

#my $uri = 'inproc://echo';



sub testing {

  my EchoServer $e;
  lives-ok {$e = EchoServer.new(:$uri) }, "EchoServer created";
  lives-ok {$e = $e.detach }, "EchoServer detached";
  ok 1, "After Detach"; 
  sleep 1; 
  lives-ok { $e._test }, "testing State";

  $c.connect($uri);
  $c.send("TESTING ECHO"); 

  my $reply = $c.receive :slurp;

  ok $reply eq 'TESTING ECHO', 'Echo replies correctly';

  lives-ok { $e.shutdown }, 'Echoserver Shutdown';
  sleep 1;
  $c.send("TESTING ECHO");# }, "echo no longer responding"; 
  sleep 1;
  $reply = $c.receive(:slurp, :async) ;
  ok $reply === Any, "no reply after shutdown";
  $c.disconnect.close;
  return True
}
#testing();
lives-ok {testing()}, "EchoServer out of scope";

done-testing;
