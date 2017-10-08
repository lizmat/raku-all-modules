#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;
use NativeCall;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;


say  "Test MsgRecv" ;

#plan ;

use Net::ZMQ::Common;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;
use Net::ZMQ::Message;

my $ctx = Context.new(:throw-everything);
my $sp1 = Socket.new($ctx, :push, :throw-everything);
my $sl2 = Socket.new($ctx, :pull, :throw-everything);
my $sp3 = Socket.new($ctx, :push, :throw-everything);
my $sl4 = Socket.new($ctx, :pull, :throw-everything);


my $uri = 'tcp://127.0.0.1:45000';
$sp1.bind($uri);
$sl2.connect($uri);
my $uri2 = 'tcp://127.0.0.1:45001';
$sp3.bind($uri2);
$sl4.connect($uri2);


my Str $str1 = "this is a nüll términated string";
my Str $str2 = "this is another beautiful string";
my Str $str3 = "tomorrow the föx wìll comê to town, ho ho ho ho!";
my  $l123 = "$str1\n$str2\n$str3".codes;
my  $l12 = "$str1$str2".codes;

my $msg = MsgBuilder.new;

$msg.add($str1);
$msg.add($str2);
$msg.add(:empty);
$msg.add($str3, :max-part-size(20));
$msg = $msg.finalize;
my Int $l1 = $msg.send($sp1);

my MsgRecv $rc .= new;

$rc.slurp( $sl2);
ok $rc.elems == $msg.segments, "msg received in {$rc.elems} parts";

$rc.push-transform(1, sub ($s) { return "--$s--" });

ok  $rc[0] eq $str1, $rc[0] ~ ' =  ' ~ $str1;
ok  $rc[1] eq "--$str2--", $rc[1] ~ ' =  ' ~ "--$str2--";
ok  $rc[2] eq '', $rc[2] ~ ' =  ';  
ok  $rc[3] eq $str3.substr(0,20), $rc[3] ~ ' =  ' ~ $str3.substr(0,20);
ok  $rc[4] eq $str3.substr(20,20), $rc[4] ~  ' =  ' ~ $str3.substr(20,20);
ok  $rc[5] eq $str3.substr(40), $rc[5] ~ ' =  ' ~ $str3.substr(40);



$rc.send($sp3);

my $rc2 = $sl4.receive :slurp;
ok $rc2 eq "$str1--$str2--$str3", "re-send succesful $rc2";

$rc.send($sp3);

my MsgRecv $rc3 .= new;
$rc3.slurp( $sl4);

$rc.push-transform(3, sub ($s) { return Any});

$rc.send($sp3, 2,3);

my $rc4 =  $sl4.receive :slurp;
ok $rc4 eq $str3.substr(20,20), "deletion/range  works: $rc4"; 
ok !$sl4.incomplete, "no leftovers";

$sp1.disconnect.close;
$sl2.unbind.close;
$sp3.disconnect.close;
$sl4.unbind.close;

done-testing;