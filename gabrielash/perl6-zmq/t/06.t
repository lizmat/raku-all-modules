#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;

say "tsting get/set scket options";

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

say  "Setting and getting socket options" ;

use-ok  'Net::ZMQ::Socket' , 'Module Socket can load';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Error;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;


my $ctx = Context.new:throw-everything;
my $s1 = Socket.new($ctx, :pair, :throw-everything);
my $s2 = Socket.new($ctx, :pair, :throw-everything);

my $omms = $s1.max-msg-size();
say "max message size = $omms";
my $mms = 512;
ok $s1.max-msg-size($mms), "s2 sets max message size  to $mms";
my $nmms = $s1.max-msg-size();
ok $nmms == $mms, "max message size was $omms, now $nmms";


my $olinger = $s1.linger();
my $linger = 500;
ok $s1.linger($linger), "s2 sets linger to 500";
my $nlinger = $s1.linger();
ok $nlinger == $linger, "linger was $olinger, now $nlinger";

my $of = $s1.fd();

my $uri = 'inproc://con';
$s1.bind($uri);
$s2.connect($uri);

my $ep = $s1.last-endpoint;
ok  $ep eq $uri, "get last-endpoint string socket option passed {($ep, $uri).perl }";

$s2.disconnect.close;
$s1.unbind.close;

done-testing;

