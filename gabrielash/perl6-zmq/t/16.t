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
my $uri = 'tcp://127.0.0.1:45000';

$c.connect($uri);


my $e = EchoServer.new(:$uri);
my $r = $e.detach;

ok $r.defined && $r.isa(Promise), 'EchoServer is running: ' ~ $r.perl;

$c.send("TESTING ECHO"); 

my $reply = $c.receive :slurp;

ok $reply eq 'TESTING ECHO', 'Echo replies correctly';

$e.shutdown;
sleep 1;
$c.send("TESTING ECHO");# }, "echo no longer responding"; 
$reply = $c.receive(:slurp, :async) ;
ok $reply === Any, "no reply after shutdown";

await $r;
pass "promise arrived";

$c.disconnect.close;

done-testing;
