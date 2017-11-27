#!/usr/bin/env perl6

unit module Log::ZMQ::Logger;

use v6;
use JSON::Tiny;

use Net::ZMQ::Context:auth('github:gabrielash');
use Net::ZMQ::Socket:auth('github:gabrielash');
use Net::ZMQ::Message:auth('github:gabrielash');

use Log::ZMQ::Common;

class Logger {...}
class Logging {...}


my %FORMATTERS = %(
        'zmq' =>
          sub (:$builder, :$prefix, :$timestamp, :$level, :$domain, :$content) {
              $builder.add($content)\
                .add($timestamp)\
        },
        'yaml' =>
          sub (:$builder, :$prefix, :$timestamp, :$level, :$domain, :$content ) {
              $builder.add(qq:to/END_YAML/)
                timestamp: $timestamp
                prefix: "$prefix"
                level: $level
                domain: $domain
                content: "$content"
                END_YAML
                #:
        },
        'json' =>
          sub (:$builder, :$prefix, :$timestamp, :$level, :$domain, :$content ) {
              my %h = qqw/ prefix $prefix level $level domain $domain /;
                %h{'content'}  = $content;
                %h{'timestamp'} = $timestamp;
                $builder.add(to-json(%h));
        }
);

my Logging $instance;
#END { $instance.DESTROY if $instance.defined; }

class Logging is export {

  has Str $.uri = $log-uri;
  has Str $.prefix;
  has $.default-level;
  has $.format;
  has Str @.domain-array;
  has %.formatters = %FORMATTERS;
  has %.domains;
  has Str $.suppress-level is rw;
  has Channel $!queue;
  has Promise $!worker;

 our proto sub instance(|)  {*}

  multi sub instance(Str $prefix, Str $uri = $log-uri
                        , :$default-level  is copy
                        , :@domain-list
                        , :$format is copy)  {
    die "Logging is already initialized. call instance wit empty argument list"
      if $instance.defined;

    my @domain-array = @domain-list > 0 ?? @domain-list !! [ '--' ];
    $default-level //= 'info';
    $format //= 'yaml';

    $instance = Logging.new(:$uri, :$default-level, :@domain-array, :$prefix, :$format);
    return $instance;
  }
  multi sub instance()  {
      return $instance if  $instance.defined;
      die "You should bring flowers on the first date";
  }

  method set-suppress-level( *%h) {
     die "what level would that '{ %h.keys }' be?" unless %h.elems == 1 and %LEVELS{ %h.keys.first}:exists;
     $!suppress-level = %h.keys.first;
  }

  method unset-suppress-level() {
    $!suppress-level = Str;
  }

  method TWEAK()  {
    die 'undefined format' unless %!formatters{ $!format}:exists or %!formatters{ $!format.key}:exists;
    $!format = $!format.key if $!format.isa(Pair);
    %!domains = zip( @!domain-array.map( { die "domain $_ is not a String"
                                          unless $_.isa(Str) ;$_ }  )
                            , (1 for 0..^@!domain-array.elems)).flat
                if @!domain-array;
    $!suppress-level = 'trace';

    $!queue .= new;
    $!worker = start {
      my Context $ctx .= new;
      my Socket $socket .= new( $ctx , :publisher );
      $socket.bind( $!uri );

      {
          say "DEBUG[QUEUR>LIST]: $_"; 
          .send($socket)
      } for $!queue.list;

      $socket.unbind.close;
      $ctx.shutdown;
    }
  }

  method set-format(Str $format where { %!formatters{ $format }:exists }) {
    $!format = $format;
    return self;
  }

  method add-formatter(Str $format, &f:((MsgBuilder, Str, Str, Str, Str, Str --> MsgBuilder ))) {
    %!formatters{ $format }  = &f;
    return self;
  }

  method logger(:$debug) {
       return  Logger.new(
                        :$debug
                        , :$!prefix
                        , :$!queue
                        , :logging(self)
                        );
}

  method DESTROY()  {
    $!queue.close;
    await $!worker;
  }
}

class Logger is export {
  has Logging $.logging is required handles < format default-level
                                              formatters domains suppress-level >;
  has Channel $.queue is required;
  has $.debug = False;
  has Str $.domain is rw;
  has Str:D $.prefix is rw is required;

  method TWEAK {
    $!domain = $!logging.domains.keys.first if $!logging.domains == 1;
  }

  method domain(Pair:D $dom) {
      die "Invalid domain, not in { self.domains.keys }" unless self.domains{ $dom.key }.exists;
      $!domain = $dom.key;
      return self;
  }


  method !suppress($level) {
    return self.suppress-level.defined
            ?? %LEVELS{ self.suppress-level } <= %LEVELS{ $level  }
            !! False;
  }

  method log-die(Str $content, *%h)  {
    say $content if $!debug;
    self.log( $content, %h{} );
    die "content";
  }

  method log(Str $content, *%h) { #say %h;say self.domains;
    say "DEBUG[Logger::log]:$content" if $!debug;  
    my $argc =  %h.elems;
    my $err = "you can specifiy a level ({ %LEVELS.keys }) and a domain ({ self.domains.keys })\n ({ %h.keys }) makes no sense";
    die $err unless $argc <= 2;
    my $domain = $!domain;
    my $level = self.default-level;


    for %h.keys  -> $k {
      if self.domains{$k}:exists {
        $domain = $k;
        --$argc;
        last;
      }
    }
    for %h.keys  -> $k {
      if %LEVELS{$k}:exists {
        $level = $k;
        --$argc;
        last;
      }
    }

    die $err unless $argc == 0;
    die "you have a domain list, but you forgot to choose one for this log message"
        unless $domain.defined;
    # args checked

    return if self!suppress($level);

    my $prefix = self.prefix;
    my $format = self.format;
    my $timestamp = DateTime.new(now).Str;
    my $builder = MsgBuilder.new\
        .add($prefix)\
        .add($domain)\
        .add($level)\
        .add($format)\
        .add(:empty);

    my  &m = self.formatters{$format};
    $builder = &m(:$builder, :$prefix, :$timestamp
                                            , :$level, :$domain,  :$content );

    say "DEBUG[Logger:log]->SENT $builder" if $!debug;
    $!queue.send($builder.finalize);
  }


}
