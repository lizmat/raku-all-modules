#!/usr/bin/env perl6

use v6.c;
use Test;

use Auth::SCRAM;
use Base64;

#-------------------------------------------------------------------------------
# Example from rfc
# C: n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL
# S: r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096
# C: c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,
#    p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
# S: v=rmF9pqV8S7suAoZWja4dJRkFsKQ=
#
#-------------------------------------------------------------------------------
# A user credentials database used to store added users to the system
# Credentials must be read from somewhere and saved to the same somewhere.
class Credentials {
  has Hash $!credentials-db;
  has Auth::SCRAM $!scram handles <start-scram s-nonce-size s-nonce>;

  #-----------------------------------------------------------------------------
  submethod BUILD ( ) {

#    $!scram .= new( :server-side(self), :basic-use);
    $!scram .= new(:server-side(self));
    isa-ok $!scram, Auth::SCRAM;
  }

  #-----------------------------------------------------------------------------
  method add-user ( $username is copy, $password is copy ) {

    $username = $!scram.saslPrep($username);
    $password = $!scram.saslPrep($password);

    $!credentials-db{$username} = $!scram.generate-user-credentials(
      :$username, :$password,
      :salt(Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118)),
      :iter(4096),
      :helper-object(self)
    );

#say '-' x 80, "\n", $!credentials-db<user> if $username eq 'user';
  }

  #-----------------------------------------------------------------------------
  method credentials ( Str $username, Str $authzid --> Hash ) {

#TODO what to do with authzid
    return $!credentials-db{$username};
  }

  #-----------------------------------------------------------------------------
  # return server first message to client, then receive and
  # return client final response
  method server-first ( Str:D $server-first-message --> Str ) {

    is $server-first-message,
       'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096',
       $server-first-message;

    < c=biws
      r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j
      p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
    >.join(',');
  }

  #-----------------------------------------------------------------------------
  # return server final message
  method server-final ( Str:D $server-final-message --> Str ) {

    is $server-final-message,
       'v=rmF9pqV8S7suAoZWja4dJRkFsKQ=',
       $server-final-message;

    '';
  }

  # method mext() is optional
  # method extension() is optional
  # method mangle-password() is optional
  # method cleanup() is optional

  #-----------------------------------------------------------------------------
  method error ( Str:D $message ) {

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
  $crd.add-user( 'gebruiker', 'potlood');
  $crd.add-user( 'utilisateur', 'crayon');

  # - command autenticate as 'user'/'pencil'
  my Str $c-nonce = encode-base64(
    Buf.new( 127, 41, 40, 249, 221, 165, 109, 177, 96,
             56, 212, 111, 246, 169, 49, 117, 172, 11
    ),
    :str
  );
  
  my Str $client-first-message = "n,,n=$test-user,r=$c-nonce";
  $crd.s-nonce = '3rfcNHYJY1ZVvWVs7j';

  is '', $crd.start-scram(:$client-first-message),
     'server side authentication of user ok';


}, 'SCRAM tests';

#-------------------------------------------------------------------------------
done-testing;
