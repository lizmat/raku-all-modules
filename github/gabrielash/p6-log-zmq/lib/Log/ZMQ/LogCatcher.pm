#!/usr/bin/env perl6

unit module Log::ZMQ::LogCatcher;

use v6;
use JSON::Tiny;

use Net::ZMQ::Context:auth('github:gabrielash');
use Net::ZMQ::Socket:auth('github:gabrielash');
use Net::ZMQ::Message:auth('github:gabrielash');

use Log::ZMQ::Common;

class LogCatcher {...}

my LogCatcher $instance;
END { $instance.DESTROY if $instance.defined; }


class LogCatcher is export {
  has Str $.uri;
  has $.debug is rw = False;

  has Int $!level-max = 3;
  has Str @!domains;
  has Context $!ctx;
  has Socket $!subscriber;
  has Promise $!promise;
  has Str $!prefix;
  has @!zmq-handlers;
  has %!handlers;

  our sub instance(Str $uri = $log-uri, :$debug)  {
    return $instance if  $instance.defined  &&  $instance.uri eq $uri;
    die "Catcher cannot be re-initialized" if $instance.defined;
    $instance = LogCatcher.new(:$uri, :$debug);
    return $instance;
  }

  method TWEAK {
    $!uri = $log-uri unless $!uri.defined;
    $!ctx = Context.new:throw-everything;
    %!handlers .= new;
    @!zmq-handlers .= new;
  }

  method DESTROY {
    self.unsubscribe if $!promise.defined;
    $!ctx.shutdown;
  }

  method !default-zmq-handler($content, $timestamp, $level, $domain) {
    say qq:to/MSG_END/;
    ___________________________________________________________________
    $level @ $timestamp (domain: $domain)
    $content
    ___________________________________________________________________
    MSG_END
    #:
  }

  method !default-handler(Str $content) {
    say '_______________________________________';
    say $content;
    say '_______________________________________';
  }

  method set-domains-filter(*@l) {
    @!domains = @l;
    return self;
  }

  multi method set-level-filter(Str:D $level where  { %LEVELS{ $level }:exists; }  ) {
    $!level-max = %LEVELS{ $level };
    return self;
  }

  multi method set-level-filter(*%h) {
    die "level must be one of { %LEVELS.keys }" unless %h.elems == 1 and  %LEVELS{ %h.keys[0] }:exists;
    $!level-max = %LEVELS{ %h.keys[0] };
    return self;
  }

  method add-zmq-handler( &f:(:$content, :$timestamp, :$level, :$domain) ) {
      @!zmq-handlers.push(&f);
      return self;
  }

  method add-handler( Str $format,  &f:(Str:D $content) ) {
      %!handlers{$format} = Array[Callable].new unless %!handlers{$format}:exists;
      my @array := %!handlers{$format};
      @array.push(&f);
      return self;
  }

  method !dispatch($msg) {
    my $begin = 0;
    $begin++ while (($begin < $msg.elems) && ($msg[$begin] ne ''));

    if $!debug {
      say "LogCatcher: DISPATCHING THIS: begin=$begin";
      say "$_) ---"  ~ $msg[$_] ~ "---" for ^$msg.elems;
    }

    return if $begin == $msg.elems;
    my $level = $msg[ $begin  + %PROTOCOL<level> ];
    return  if %LEVELS{$level} > $!level-max;
    my $domain = $msg[ $begin + %PROTOCOL<domain> ];
    return if @!domains > 0 && ! @!domains.grep( { $_ eq $domain } );

    my $format = $msg[$begin   + %PROTOCOL<format> ];

    given $format {
      when  'zmq' {
        return unless $begin + 1 < $msg.elems;
        my $content =  $msg[ $begin + %PROTOCOL<content> ];
        my $timestamp = $msg[ $begin + %PROTOCOL<timestamp> ];

        if @!zmq-handlers.elems > 0 {
          $_(:$content, :$timestamp, :$level, :$domain)
            for @!zmq-handlers;
        } else {
          self!default-zmq-handler($content, $timestamp, $level, $domain);
        }
      }
      default {
        return unless $begin + 1 < $msg.elems;
        my $content =  $msg[ $begin + %PROTOCOL<content> ];
        if %!handlers{$format}:exists {
          my @handlers = %!handlers{$format};
          $_($content) for @handlers;
        } else {
          self!default-handler($content);
        }
      }
    }
  }#!dispatch

  method run(Str:D $prefix) {
    $!prefix = $prefix;
    $!subscriber = Socket.new($!ctx, :subscriber, :throw-everything);
    $!subscriber.connect($!uri);
    $!subscriber.subscribe($prefix);
    loop {
          my MsgRecv $m .= new;
          $m.slurp($!subscriber);
          $m.set-encoding( 'UTF-8' );
          die "BAD Transform" unless $m[0].WHAT === Str;
          self!dispatch($m);
    }
  }


  method subscribe(Str:D $prefix) {
    $!promise = start {
      self.run($prefix);
    }
    return $!promise.defined;
  }

  method unsubscribe(:$async) {
    if ($!promise.defined) {
        $!promise.break;
        CATCH{
          when  X::Promise::Vowed {
            $!subscriber.unsubscribe($!prefix);
            $!subscriber.disconnect.close;
          }
          # this doesn't work, because every exception breaks the promise
          # which means there is effectively no error reporting inside the promise
          # so this has to be redesigned
          default { .throw; }
      }
    }
    #say "LogCatcher: exit Promise";
    $!promise = Promise;
  }


}#LogCatcher
