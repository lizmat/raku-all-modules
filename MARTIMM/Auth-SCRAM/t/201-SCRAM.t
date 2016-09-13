#!/usr/bin/env perl6

use v6.c;
use Test;

use Auth::SCRAM;
use Base64;

#-------------------------------------------------------------------------------
my Str $expected-error = '';
#-------------------------------------------------------------------------------
# A user credentials database used to store added users to the system
# Credentials must be read from somewhere and saved to the same somewhere.
class Credentials {
  has Hash $!credentials-db;
  has Auth::SCRAM $!scram handles <start-scram s-nonce-size s-nonce>;

  # Salt must be generated unique for each username but it is fixed for the test
  has Buf $!salt .= new((for ^6 { (rand * 256).Int }));
  has Int $!iter = 1000;

  #-----------------------------------------------------------------------------
  submethod BUILD ( ) {

    $!scram .= new(:server-side(self));
    isa-ok $!scram, Auth::SCRAM;
  }

  #-----------------------------------------------------------------------------
  method add-user ( $username is copy, $password is copy ) {

    for $!scram.generate-user-credentials(
      :$username, :$password,
      :$!salt, :$!iter,
      :helper-object(self)
    ) -> $u, %h {
      $!credentials-db{$u} = %h;
    }
  }

  #-----------------------------------------------------------------------------
  method credentials ( Str $username, Str $authzid --> Hash ) {

#TODO what to do with authzid
    return $!credentials-db{$username} // {};
  }

  #-----------------------------------------------------------------------------
  # return server first message to client, then receive and
  # return client final response
  method server-first ( Str:D $server-first-message --> Str ) {

    my Str $s = encode-base64( $!salt, :str);
    ok $server-first-message ~~ m/^ 'r=' <-[,]>+ ",s=$s"/,
         $server-first-message;

    $server-first-message ~~ m/^ 'r=' $<cs-nonce>=(<-[,]>+) /;

    # Send wrong proof
    my Str $rs = (
      'c=biws',
      "r=" ~ $/<cs-nonce>.Str,
      "p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts="
    ).join(',');

    $rs;
  }

  #-----------------------------------------------------------------------------
  # return server final message
  method server-final ( Str:D $server-final-message --> Str ) {

    is $server-final-message,
       'v=rmF9pqV8S7suAoZWja4dJRkFsKQ=',
       $server-final-message;

    '';
  }

  # method authzid() is optional
  # method mext() is optional
  # method extension() is optional
  # method mangle-password() is optional
  # method cleanup() is optional

  #-----------------------------------------------------------------------------
  method error ( Str:D $message ) {

    is $message, $expected-error, "expected error: '$expected-error'";
  }
}

#-------------------------------------------------------------------------------
subtest {

  # Server actions in advance ...
  # - set up shop
  my Credentials $crd .= new;

  # - set up socket
  # - listen to socket and wait
  # - input from client
  # - fork process, parent returns to listening on socket
  # - child processes input as commands

  # - command is add a user
  my Str $test-user = 'user';
  $crd.add-user( $test-user, 'pencil');

  # - command autenticate as 'user'/'pencil'
  my Str $c-nonce = encode-base64(
    Buf.new((for ^10 { (rand * 256).Int })),
    :str
  );

  $expected-error = 'e=unknown-user';
  my Str $client-first-message = "n,,n=otheruser,r=$c-nonce";
  $crd.start-scram(:$client-first-message);

  $expected-error = 'e=invalid-proof';
  $client-first-message = "n,,n=$test-user,r=$c-nonce";
  $crd.start-scram(:$client-first-message);

  $expected-error = 'e=invalid-proof';
  $client-first-message = "n,,n=$test-user,r=654def56";
  $crd.start-scram(:$client-first-message);

  $expected-error = 'e=invalid-encoding';
  $client-first-message = "n,,n=u1=2cdata=f,r=$c-nonce";
  $crd.start-scram(:$client-first-message);

}, 'SCRAM tests';

#-------------------------------------------------------------------------------
done-testing;
