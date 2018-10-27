#!/usr/bin/env perl6

use v6.c;
use Test;

use Auth::SCRAM;

#-------------------------------------------------------------------------------
# Example from rfc
# C: n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL
# S: r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096
# C: c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,
#    p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
# S: v=rmF9pqV8S7suAoZWja4dJRkFsKQ=
#
class MyClient {

  #-----------------------------------------------------------------------------
  # send client first message to server and return server response
  method client-first ( Str:D $client-first-message --> Str ) {

    is $client-first-message,
       'n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL',
       $client-first-message;

    'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096';
  }

  #-----------------------------------------------------------------------------
  method client-final ( Str:D $client-final-message --> Str ) {

    is $client-final-message,
       < c=biws r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j
         p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
       >.join(','),
       $client-final-message;

    'v=rmF9pqV8S7suAoZWja4dJRkFsKQ=';
  }

  # method mangle-password() is optional
  # method cleanup() is optional

  #-----------------------------------------------------------------------------
  method error ( Str:D $error-message --> Str ) {

  }
}

#-------------------------------------------------------------------------------
subtest {

  my Auth::SCRAM $sc .= new(
    :username<user>,
    :password<pencil>,
    :client-object(MyClient.new)
  );
  isa-ok $sc, Auth::SCRAM;

  $sc.c-nonce = 'fyko+d2lbbFgONRv9qkxdawL';

  is '', $sc.start-scram, 'client side authentication of user ok';

}, 'SCRAM tests';

#-------------------------------------------------------------------------------
done-testing;
