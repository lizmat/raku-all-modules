# Net::ZMQ

## SYNOPSIS

Net::ZMQ is a Perl6 binding library for ZeroMQ

## Introduction

#### Status

This is in development. The only certainty is that the tests pass on my machine.  

#### Alternatives

There is an an earlier project on github:  https://github.com/arnsholt/Net-ZMQ
I started this one primarily to learn both Perl6 and ZMQ. The older project
may be more stable and suitable to your needs. If you do boldly go and use this
one, please share bugs and fixes!

#### ZMQ Versions

Current development is with ZeroMQ 4.2. Unfathomably, version 4
is installed on my system as libzmq.so.5. The NativeCall calls are
therefore to v5.

#### Portability

Development is on linux/x64. Due to some pointer voodoo, it is likely the code
will break on other architectures/OSes. This should not be too hard to fix, but
it depends on other people trying it on other platforms.

## Example Code

    use v6;
    use Net::ZMQ::V4::Constants;
    use Net::ZMQ::Context;
    use Net::ZMQ::Socket;
    use Net::ZMQ::Message;

    my Context $ctx .= new :throw-everything;
    my Socket $s1 .= new($ctx, :pair, :throw-everything);
    my Socket $s2 .= new($ctx, :pair, :throw-everything);

    my $endpoint = 'inproc://con';
    $s1.bind($endpoint);
    $s2.connect($endpoint);

    my $counter = 0;
    my $callme = sub ($d, $h) { say 'sending ++$counter'};

    MsgBuilder.new\
          .add('a short envelope' )\
          .add( :newline )\
          .add( :empty )\
          .add('a very long story', :max-part-size(255), :newline )\
          .add('another long chunk à la française', :divide-into(3), :newline )\
          .add( :empty )\
          .finalize\
          .send($s1, :callback( $callme ));

    my $message = $s2.receive( :slurp );
    say $message;

    $s1.unbind.close;
    $s2.disconnect.close;

## Documentation

####  Net::ZMQ::V4::Constants

holds all the constants from zmq.h v4. They are grouped with tags.
The tags not loaded by default are
* :EVENT
* :DEPRECATED
* :DRAFT 	Experimental, not in stable version
* :RADIO
* :IOPLEX	multiplexing
* :SECURITY

####  Net::ZMQ::V4::LowLevel

holds NativeCall bindings for all the functions in zmq.h
most calls are machine generated and the only check is that they compile.
constant ZMQ_LOW_LEVEL_FUNCTIONS_TESTED holds a list of the calls used and tested
in the module so far. loading  Net::ZMQ::V4::Version prints it

####  Net::ZMQ::V4::Version
use in order to chack version compatibility. It exports
* verion()
* version-major()

####  Net::ZMQ::Context, ::Socket, ::Message, ::Poll

These are the main classes providing a higher-level Perl6 OO interface to ZMQ

#####    Context
	         .new( :throw-everything(True))      # set to True to throw non fatal errors
	         .terminate() 			                 # manually release all resources (gc would do that)
	         .shutdown()			                   # close all sockets
	         .get-option(name)                   # get Context option
	         .set-option(name, value)	           # set Context option

	          options can also be accessed through methods with the name of the option
	          with/without get- and set- prefixes.
	             e.g get: .get-io-threads()  .io-threads()
	             set: .set-io-threads(2) .io-threads(2)
	          Net::ZMQ::ContextOptions holds the dispatch table

#####    Socket

    Attributes
      context   - the zmq-context; must be supplied to new()
      type      - the ZMQ Socket Type constant: One of
        :pair :publisher :subscriber :client :server :dealer :router :pull :push :xpub :xsub :stream
        must be supplied to new()
      last-error - the last zmq error reported
      throw-everything  - when true, all non-fatal errors except EAGAIN (async) throw
      async-fail-throw  - when true, EAGAIN (async) throws; when false EAGAIN returns Any
      max-send-bytes    - largest single part send in bytes
      max-recv-number   - longest charcter string representing an integer number
                          in a single, integer message part
      max-recv-bytes    - bytes threshhold for truncating receive methods

    Methods
    Methods that do not return a useful value return self on success and Any on failure.
    Send methods return the number of bytes sent or Any.

    Socket Wrapper Methods
        close()
        bind( endpoint --> self )         ;endpoint must be a string with a valid zmq endpoint
        unbind( endpoint = last-endpoint  --> self )
        connect( endpoint  --> self )
        disconnect( endpoint = last-endpoint --> self )

    Send Methods
          -part sends with SNDMORE flag (incomplete)
          -split causes input to be split and sent in message parts
          -async duh!
          all methods return the number of bytes sent or Any
        send( Str , :async, :part --> Int)
        send( Int, :async, :part -->Int )
        send( buf8, :async, :part, :max-send-bytes -->Int )
        send(Str, Int split-at :split! :async, :part -->Int )
        send(buf8, Int split-at :split! :async, :part -->Int )
        send(buf8, Array splits, :part, :async, :callback, :max-send-bytes -->Int )
        send(:empty!, :async, :part -->Int )        

    Receive Methods
          -bin causes return type to be a byte buffer (buf8) instead of a string
          -int retrieves a single integer message
          -slurp causes all waiting parts of a message to be aseembled and returned as single object
          -truncate truncates at a maximum byte length
          -async duh!
        receive(:truncate!, :async, :bin)
        receive(:int!, :async, :max-recv-number --> Int)
        receive(:slurp!, :async, :bin)
        receive(:async, :bin)

    Options Methods
        there are option getters and setter for every socket option
        the list of options is in SocketOptions.pm
        every option name creates four legal invocations
          -setters
            option-name(new-value)
            set-option:$name(new-value)
          -getters
            option-name()
            get-option-name()
            e.g.
            * .get-identity()  .identity()
            * .set-identity(id) .identity(id)
        options can also be accessed explicitly with the ZMQ option Constant.
            valid Type Objects are Str, buf8 and Int
            get-option(Int opt-contant, Type-Object return-type, Int size )

    Misc Methods
        doc(-->Str) ;this

    The Message class is an OO interface to the zero-copy mechanism.
    It uses a builder to build an immutable message that can be sent (and re-sent)
    zero-copied. See example above for useage.


#####    MsgBuilder
      builds a Message object that can be used to send complex messages.
      uses zero-copy internally.

      USAGE example

          my MsgBuilder $builder  .= new;
          my Message $msg =
            $builder.add($envelope)\
                    .add(:empty)\
                    .add($content-1, :max-part-size(1024) :newline)\
                    .add($content-2, :max-part-size(1024) :newline)\
                    .finalize;

          $msg.send($socket);


    Methods
        new()
        add( Str, :max-part-size :divide-into, :newline --> self)
        add( :empty --> self)
        add( :newline --> self)
        finalize( --> Message)

#####   Message
  	Immutable message     

    Methods
        send(Socket, :part, :async, Callable:($,$ --> Int:D) :callback  --> Int)                  
        send-all(@sockets, :part, :async, Callable:($,$ --> Int:D) :callback  --> Int)
        bytes( --> Int)          
        segments( --> Int)  
        copy( --> Str)

#####  MsgRecv
    MsgRecv accumulates message parts received on one or more sockets with minimal copying.
    parts can be examined, slectevely sent over sockets. and transforming functions can be
    queued on each part.

    methods:
        slurp(Socket, :async)
                  accumulate waiting message parts from a socket
        push-transform(UInt, &func)
                  queue a transfrm function on a message part. The function should
                  conform to :(Str:D --> Str:D|Any ). Any effectively delete the part.         
        send(Socket, $from = 0, $n = elems, :async ) sends all or ome of the parts
        [ UInt ] returns message part as Str



#####   PollBuilder
    PollBuilder builds a polled set of receiving sockets

    (Silly) Usage
    my $poll = PollBuilder.new\
      .add( StrPollHandler.new( $socket-1, sub ($m) { say "got --$m-- on  socket 1";} ))\
      .add( StrPollHandler.new( $socket-2, sub ($m) { say "got --$m-- on  socket 2";} ))\
      .add( $socket-3, { False })\
      .delay( 500 )\
      .finalize;

    1 while $poll.poll(:serial);
    say "Done!";


     Methods
      add( PollHandler --> self)
      add( Socket, Callable:(Socket) --> self)  
      delay( Int msecs --> self)                #   -1 => blocks, 0 => no delay
      finalize( --> Poll)

#####  PollHandler
    PollHandler is an an abstract class that represents an action to do on a socket when
    it polls positive. It has four readymade subclasses that feed the action a different
    argument:
        * StrPollHandler
        * MessagePollHandler
        * SocketPollHandler
        * MsgRecvPollHandler

    Methods
      new( Socket, Callable:(T) )
      do( Socket )  --  this method is called by the Poll object and can be subclassed
                        to create new types of responses


#####  Poll
    Poll holds and polls an  immutable collection of receiving sockets

    Methods
    poll()   
      poll returns a sequence of the results of the callback functions associated with the succesfully
      polled sockets or an empty sequence. It throws on error.
    poll(:serial)
      primarily fo testing: returns a single result, from the callback of the first succesfully polled
      socket, or Any. The order is defined by the building invocation.

#####  Proxy
    runs a steerable proxy

    new( :frontend!($socket.as-ptr), :backend!($socket.as-ptr)
            :capture($socket.as-ptr) , :control($socket.as-ptr))
    run()

## LICENSE

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

ⓒ 2017 Gabriel Ash
