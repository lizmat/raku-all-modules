#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

say  "Sending and receiving a binary file";

use-ok  'Net::ZMQ::Socket' , 'Module Socket can load';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Error;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;


say "testing passing ~9k binary file"; 

my $ctx = Context.new(:throw-everything);
my $s1 = Socket.new($ctx, :pair, :throw-everything);
my $s2 = Socket.new($ctx, :pair, :throw-everything);

pass "Sockets created ...pass";

my $uri = 'inproc://con';

lives-ok  {$s1.bind($uri)}, 's1 binds succesfully' ;
lives-ok  {$s2.connect($uri)}, 's2 connects succesfully' ;;


my $ex = shell "cd lib/Local && make hello";

my $filename = 'dump';
$ex = shell "rm -f $filename > /dev/null 2>&1" ;

if $ex {

my buf8 $raw = slurp "lib/Local/hello", :bin;

my int64 $lraw = $raw.bytes;
say "transferring binary file with $lraw bytes";
my $lrawr =  $s1.send($raw);
ok $lraw = $lrawr, "binary file transfered to C counted correctly";

my $rcvd = $s2.receive :bin;
ok $lrawr == $rcvd.bytes , "received binary { $rcvd.bytes }" ;

spurt "$filename", $rcvd, :bin, :createonly;
ok  0 == shell "chmod a+x $filename";
my $output = qq:x! "./$filename"!;
ok $output eq "Hello World\n", "running transferd binary passed";

$ex = shell "rm -f $filename";
$ex = shell "cd lib/Local && make clean";

pass "file reconstituted correctly";

} else {
  say "no C compiler capability, skipping test" ;
}

$s2.disconnect.close;
$s1.unbind.close;
pass "closing sockets pass";


done-testing;
