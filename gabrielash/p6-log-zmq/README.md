# Log::ZMQ

## SYNOPSIS

Log::ZMQ is a Perl6 Logger using zeromq to log over tcp/ip

## Introduction

A decoupled remote logger. The client sends log meesages from the application to a
LogCatcher listening on a tcp port.

The backend uses a publisher-subscriber pattern, suitable for debugging asynchronous
apps (by sheer luck, the purpose of writing it) but not much else. A more general 
framework would require changing the pattern.

Setup is minimal: A single application-wide call to Logging::instance with arguments, 
plus no-parameters call for each additinal place in the code that wants to hold its own logger. 
Enumerated arguments can be entered with colon notation and it is possible to set defaults 
and log with no extra arguments. A global .set-supress-level( :level)  can turn all
logging off. When suppressed, log calls incur only the cost of argument checking.

Format is a choice of json, yaml and a raw format based on ZMQ frames. It can be 
extended on both sides with user-provided functions. On the backend,
there is currently no distinction between adding parsers and adding handlers. The 
built-in parsers-handelrs all write the logged message in multiline to STDOUT 
(useful for debugging, not so much for monitoring.)

#### Status

In development. This is my learning process of perl6 and ZMQ. I have a lot to learn so use with care.


#### Portability
  depends on Net::ZMQ:auth('github:gabrielash');

## Example Code

#### A (minimal)
    my $l = Logging::instance( 'example' ).logger;
    $l.log( 'an important message');

    my $l2 = Logging::instance.logger;
    $l2.log( 'another important message');

#### B ( more elaborate )
    my $logger = Logging::instance('example', 'tcp://78.78.1.7:3301')\
                                , :default-level( :warning )\
                                , :domain-list( < database engine front-end nativecall > )\
                                , :format( :json ))\
                          .logger;      

    $logger.log( 'a very important message', :critical, :front-end );

    my $db-logger = Logging::instance.logger.domain( :database );
    $db-logger.log( 'meh');

#### C (the log catcher on the other side )
    # on the command line:
    log-catcher.pl --uri 'tcp://78.78.1.7:3301' --prefix example \
                        	       --level debug database front-end

## Documentation

#### Log::ZMQ::Logging

  The logging framework based on ZMQ. Usually a singleton summoned with

    my $log-system = Logging::instance('prefix', ['tcp://127.127.8.17:8022', ... ]) ;
        ;  only supply parameters the first time

    The default uri is 'tcp://127.0.0.1:3999'

    Attributes
    prefix;   required
    default-level; (default = info)
    format;   default yaml
    domain-list; default ('--')            ;if left blank no domain is required below

  Methods
    logger()  ; returns a Logger
    set-supress-level(:level)               ;silences logging globally
    unset-supress-level()
    add-formatter()                         ;see below
    set-format()                            ;must use this after adding a formatter


#### Log::ZMQ::Logger

The logger

    Methods
      log( log-message, :level, :domain )
        ; level is optional.
        ; domain is optional only if a domain list is not set


The logging uses a publisher socket. All protocols send 5 frames
  1. prefix
  2. domain
  3. level
  4. format [ zmq | yaml | json | ... ]
  5. empty frame

followed with frames that depend on the format.
For zmq:
  6. content
  7. timestamp
  8. target

for yaml/json:
  6. yaml/json formatted  

To add custom formatter, use instance.add-formatter.  
  :(MsgBuilder :builder, :prefix, :timestamp, :level, :domain,  :content
                        --> MsgBuilder ) {
  ... your code here ...
  return $builder;
  }
    the builder should be returned unfinalized.
  then set the format:
    set-format('name');

#### Log::ZMQ::catcher

handles the logging backend, listening to zmq messages.

The wrapper script log-catcher.pl can be invoked from the cli. to see options:
    log-catcher.pl --help

This is the body of the MAIN sub

    my $c = $uri.defined ?? LogCatcher::instance(:$uri, :debug )
                          !! LogCatcher::instance( :$debug );
    $c.set-level-filter( $level);
    $c.set-domains-filter(| @domains) if @domains;
    $c.run($prefix);

current implemention print the received messaged to stdout. other backends can be added
with the following methods:

  * add-zmq-handler( &f:(:$content, :$timestamp, :$level, :$domain, :$target) )
  * add-handler( Str $format,  &f:(Str:D $content) )


## LICENSE

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

ⓒ 2017 Gabriel Ash
