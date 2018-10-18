#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;
use NativeCall;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

say  "Test MsgBuilder doc example" ;

use-ok  'Net::ZMQ::Common' , 'Common functions loaded';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;
use Net::ZMQ::Message;

  my Context $ctx .= new :throw-everything;
  my Socket $s1 .= new( $ctx, :pair, :throw-everything);
  my Socket $s2 .= new( $ctx, :pair, :throw-everything);
  my $endpoint = 'inproc://con';
  $s1.bind($endpoint);
  $s2.connect($endpoint);

  MsgBuilder.new\
          .add('a short envelope' )\
          .add( :newline )\
          .add( :empty )\
          .add('a very long story', :max-part-size(255), :newline )\
          .add('another long chunk à la française', :divide-into(3), :newline )\
          .add( :empty )\
          .finalize\
          .send($s1);

  my $message = $s2.receive( :slurp);
  say $message;

  $s1.unbind.close;
  $s2.disconnect.close;


done-testing;
