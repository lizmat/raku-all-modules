use v6;

use MongoDB;

use BSON::Document;
use Base64;
use OpenSSL::Digest;
use Digest::MD5;

#-------------------------------------------------------------------------------
#`{{
https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst#scram-sha-1

This document describes how SCRAM is implemented for mongodb. They do not
follow the rfc exact to the description therein (sic). So a few things needed
to be changed in this class.
}}

#-------------------------------------------------------------------------------
unit package MongoDB:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
# Class definition to do authentication with
class Authenticate::Scram {

  has ClientType $!client;
  has DatabaseType $!database;
  has Int $!conversation-id;

#TODO waiting for the mongodb issue to resolve.
  has Str $!username;
  has Str $!password;

  #-----------------------------------------------------------------------------
  submethod BUILD (
    ClientType:D :$client, Str :$db-name, Str :$!username, Str :$!password
  ) {

    $!client = $client;
    $!database = $!client.database(?$db-name ?? $db-name !! 'admin');
  }

  #-----------------------------------------------------------------------------
  # send client first message to server and return server response
  method client-first ( Str:D $client-first-message --> Str ) {

    trace-message("client first msg: $client-first-message");
    my BSON::Document $doc = $!database.run-command( BSON::Document.new: (
        saslStart => 1,
        mechanism => 'SCRAM-SHA-1',
        payload => encode-base64( $client-first-message, :str)
      )
    );

    if $doc<ok> {
      debug-message("SCRAM-SHA1 client first message");
    }

    else {
      fatal-message("$doc<code>, $doc<errmsg>");
#      return '';
    }

    $!conversation-id = $doc<conversationId>;
    Buf.new(decode-base64($doc<payload>)).decode
  }

  #-----------------------------------------------------------------------------
  method client-final ( Str:D $client-final-message --> Str ) {

    trace-message("client final msg: $client-final-message");
    my BSON::Document $doc = $!database.run-command( BSON::Document.new: (
        saslContinue => 1,
        conversationId => $!conversation-id,
        payload => encode-base64( $client-final-message, :str)
      )
    );
    trace-message("Result client final: {($doc//{}).perl}");

    if $doc<ok> {
      debug-message("SCRAM-SHA1 client final message");
    }

    else {
      fatal-message("$doc<code>, $doc<errmsg>");
#      return '';
    }

    Buf.new(decode-base64($doc<payload>)).decode
  }

  #-----------------------------------------------------------------------------
#  method mangle-password ( Str:D :$username, Str:D :$password --> Buf ) {
  method mangle-password ( Str:D :$!username, Str:D :$!password --> Str ) {

#note "un, pw: $username, $password";
# MongDB says to not prep the username and password => args are ignored
    #my utf8 $mdb-hashed-pw = ($username ~ ':mongo:' ~ $password).encode;
    my Str $md5-mdb-hashed-pw = Digest::MD5.new.md5_hex(
      $!username ~ ':mongo:' ~ $!password   #$mdb-hashed-pw
    ); #>>.fmt('%02x').join;
#    Buf.new($md5-mdb-hashed-pw.encode)
#note "Hashed pw: $md5-mdb-hashed-pw";
    $md5-mdb-hashed-pw
  }

  #-----------------------------------------------------------------------------
  method cleanup ( ) {

    # Some extra chit-chat
    my BSON::Document $doc = $!database.run-command( BSON::Document.new: (
        saslContinue => 1,
        conversationId => $!conversation-id,
        payload => encode-base64( '', :str)
      )
    );

    if $doc<ok> {
      info-message("SCRAM-SHA1 autentication successfull");
    }

    else {
      fatal-message("$doc<code>, $doc<errmsg>");
    }
  }

  #-----------------------------------------------------------------------------
  method error ( Str:D $message --> Str ) {

    fatal-message($message);
    ''
  }
}
