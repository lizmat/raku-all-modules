#!/usr/bin/env perl6

unit module Net::Jupyter::Messenger;

use v6;

use Net::Jupyter::Common;


use Net::ZMQ::Message:auth('github:gabrielash');
use Net::ZMQ::Socket:auth('github:gabrielash');

use Log::ZMQ::Logger;

use JSON::Tiny;
use Digest::HMAC;
use Digest::SHA256::Native;



sub new-header($type, $session) {
    return qq:to/HEADER_END/;
      \{"date": "{ DateTime.new(now) }",
      "msg_id": "{ uuid() }",
      "username": "kernel",
      "session": "$session",
      "msg_type": "$type",
      "version": "5.0"\}
      HEADER_END
     #:
}

class Messenger is export {
  has MsgRecv $.msg is required;
  has Str $.session-key is required;
  has Str $.key;
  has Logger $.logger;

  has UInt $!begin;


  method TWEAK {
    $!begin = self!find-begin;
    $!msg.set-encoding( 'UTF-8');
    $!logger.log(self.Str) if $!logger.defined;
    #say self.Str;

    die "signature mismatch. Exiting" ~ $!msg.perl
      unless self.auth(self.signature);

   }

  method !find-begin( --> Int ) {
    for 0..^$!msg.elems {
      $!msg.push-transform($_,  sub ($b) { $b.decode('ISO-8859-1') } );
      return $_ if $!msg[$_] eq DELIM;
    }
    die "malformed wire message " ~ $!msg.perl;
  }

  method identities( --> List)     {  return  $!msg[ ^$!begin ]  }
  method extra( --> List)          {  return $!msg[ ($!begin + 6)..^$!msg.elems] }

  method signature               {  return $!msg[$!begin + 1] }
  method header                  {  return $!msg[$!begin + 2] }
  method parent-header           {  return $!msg[$!begin + 3] }
  method metadata                {  return $!msg[$!begin + 4] }
  method content                 {  return $!msg[$!begin + 5] }

  method id             {return from-json(self.header)< msg_id > }
  method type           {return from-json(self.header)< msg_type > }
  method version        {return from-json(self.header)< version > }

  method code           {return from-json(self.content)< code > }
  method silent         {return from-json(self.content)< silent > }
  method store-history   {return from-json(self.content)< store_history > }
  method expressions    {return from-json(self.content)< user_expressions > }


  method auth(Str $signature --> Bool) {
    return True unless $.key.defined;
    return ($signature eq hmac-hex($!key, $!msg.raw-at($!begin + 2)
                                          ~ $!msg.raw-at($!begin + 3)
                                          ~ $!msg.raw-at($!begin + 4)
                                          ~ $!msg.raw-at($!begin + 5)
                                        , &sha256));
  }

  method send(Socket:D $stream, Str:D $type, Str $content!,
                Str :$parent-header!, Str :$metadata = '{}', :@identities!) {
      my $header = new-header($type, $!session-key);
      my $signature;
      try {
        $signature =  hmac-hex($!key, $header ~ $parent-header ~ $metadata ~ $content,  &sha256);
        CATCH {
          default {
            say $!key;
            say $header ~ $parent-header ~ $metadata ~ $content;
            die $_.message;}}}

      my MsgBuilder $m .= new;
      @identities.map( { $m.add($_) } );
      say "IDENTITIES: ", @identities;

      my Message $msg = $m.add(DELIM)\
                          .add($signature)\
                          .add( $header )\
                          .add( $parent-header )\
                          .add($metadata)\
                          .add( $content )\
                          .finalize;
      $msg.send($stream);

      $!logger.log($msg.copy) if $!logger.defined;
  }

  method Str() {
    return qq:to/END/;
      header: { self.type } { self.version } { self.id } {self.signature }
      identities: { self.identities.gist }
      content: { self.content}
      header: { self.header}
      parent-header: { self.parent-header}
      metadata: { self.metadata }
      END
      #:
  }



}#Receiver
