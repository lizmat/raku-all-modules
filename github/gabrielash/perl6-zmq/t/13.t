#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;
use NativeCall;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

say  "Polling testing" ;

#use-ok  'Net::ZMQ::Poll' , 'Module Poll loads ok';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;
use Net::ZMQ::Message;
use Net::ZMQ::Poll;




  my Context $ctx .= new :throw-everything;
  my Socket $c  .= new( $ctx, :push, :throw-everything);
#  my $endpoint = 'inproc://con';

  my $endpoint = 'tcp://127.0.0.1:6000';
  $c.bind($endpoint);
  sleep 2;

my $p2 = start {
  my Context $ctx .= new :throw-everything;
  my Socket $s1 .= new( $ctx, :pull, :throw-everything);
  my Socket $s2 .= new( $ctx, :pull, :throw-everything);
  my Socket $s3 .= new( $ctx, :pull, :throw-everything);
  my Socket $s4 .= new( $ctx, :pull, :throw-everything);

  $s1.connect($endpoint);
  $s2.connect($endpoint);
  $s3.connect($endpoint);
  $s4.connect($endpoint);

  my $poll = PollBuilder.new()\
        .add(StrPollHandler.new( $s1, sub ($m) { ok $m, "**1**"; return "got message --$m-- on  socket 1";} ))\
        .add(StrPollHandler.new( $s2, sub ($m) { ok $m, "**2**"; return "got message --$m-- on  socket 2";} ))\
        .add(StrPollHandler.new( $s3, sub ($m) { ok $m,  "**3**"; return "got message --$m-- on  socket 3";} ))\
        .add($s4, sub ($s) { say "**4**"; return ($s.receive  eq 'STOP') ?? False !! "got message on socket 4";})\
        .delay(500)\
        .finalize;

      ok $poll.defined, "Poll Built";
#      say $poll.perl;
#      $poll.str;

      my $cnt = 0;
      loop {
        my @r = $poll.poll;
	say "got", @r;
        say "got { @r.elems } -> { $cnt += @r.elems }" if @r; 
        last if @r.grep(  { $_ === False } );
      }
     ok $cnt == 8, "received all $cnt";
     ok True, "loop ended. pulls Done!";
     
    $s1.disconnect.close;
    $s2.disconnect.close;
    $s3.disconnect.close;
    $s4.disconnect.close;
    say "everything closed";
}

sleep 2;
my $cnt = 0; 
for 0..^4 {my $sent =  $c.send("Hello"); say "Hello sent ",++$cnt;};
for 0..^4 {sleep 1;my $sent =  $c.send("STOP"); say "STOP sent ", ++$cnt;};

ok $cnt == 8, "Total count is  $cnt";


$c.disconnect.close;

await $p2;


done-testing;
