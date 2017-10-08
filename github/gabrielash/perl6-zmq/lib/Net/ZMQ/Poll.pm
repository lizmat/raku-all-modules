#!/usr/bin/env perl6

unit module Net::ZMQ::Poll;
use v6;
use NativeCall;

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::V4::Constants :DEFAULT, :IOPLEX ;

use Net::ZMQ::Error;
use Net::ZMQ::Common;
use Net::ZMQ::Socket;
use Net::ZMQ::Message;

my %poll-events = incoming => ZMQ_POLLIN
                  , outgoing => ZMQ_POLLOUT;

class PollBuilder {...}


class PollHandler is export {
  my $doc = q:to/END/;
    A PollHandler holds a response to a POLLIN notification on a polled
    socket set. It is registered with PollBuilder.add().
    It can be subclassed and the do() method overriden with the desired behaviour.

    Attributes
      socket - the socket
      action[0] - a Callback for dynamic, poll-driven behaviour

    Methods
      do( Socket )   - is called by the Poll object. standard implementations
      call action[0] with the class specific argument (Socket, Str, or Message)

  END
  #:

  has Socket $.socket is required;
  has Callable @.action is required;
  # if a scalar is used, it is called as a method unfortunately, so we hide in an array

  submethod BUILD(:$socket, :$action) { $!socket = $socket;  @!action[0] = $action }
  method new(Socket $socket, Callable $action ) { return self.bless(:$socket, :$action) }

  method do() {die "PollHandler is abstract";}
  method doc {$doc};
}

class SocketPollHandler is PollHandler is export {
  my $doc = q:to/END/;
    A PollHandler that calls action(Socket) in do(Socket)
  END
  #:
  method do( Socket:D $socket ) {
    return @.action[0]( $socket );
  }
}

class StrPollHandler is PollHandler is export {
  my $doc = q:to/END/;
    A PollHandler that calls action(Str FullMessage) in do(Socket)
  END
  #:
  method do(Socket:D $socket ) {
      return @.action[0]( $socket.receive( :slurp) );
  }

}

class MessagePollHandler is PollHandler is export {
  my $doc = q:to/END/;
    A PollHandler that calls action(Msg FullMessage) in do(Socket)
  END
  #:

  method do(Socket:D $socket ) {
    my MsgBuilder $builder .= new;
    repeat {
      $builder.add($socket.receive);
    } while $socket.incomplete;
    return @.action[0]( $builder.finalize );
  }
}

class MsgRecvPollHandler is PollHandler is export {
  my $doc = q:to/END/;
    A PollHandler that calls action(MsgRecv Message) in do(Socket)
  END
  #:

  method do(Socket:D $socket ) {
    my MsgRecv $recv .= new;
    $recv.slurp( $socket); 
    return @.action[0]( $recv );
  }
}

class Poll-impl {
  my $doc = q:to/END/;
    Implementation of Poll
  END
  #:

  has PollHandler @.items is rw handles < elems >;
  has Int $.delay is rw = Int;
  has @.c-items is rw;

  method add( PollHandler:D $pr  ) {
    @!items.push( $pr );
  }

  method finalize()   {
    @!c-items := CArray-CStruct[ zmq_pollitem_t ].new(self.elems);

    for ^self.elems -> $n {
      @!c-items[$n].socket = @!items[$n].socket.handle;
      @!c-items[$n].fd = 0;
      @!c-items[$n].events = %poll-events<incoming>;
      @!c-items[$n].revents = 0;
    }
  }

  multi method poll(:$serial!) {
    die "cannot poll un unfinalized Poll" unless @!c-items.defined;
    throw-error()  if -1 == zmq_poll( @!c-items.as-pointer, self.elems, $!delay);
    for ^self.elems -> $n {
        return @!items[$n].do( @!items[$n].socket )
          if ( @!c-items[$n].revents +& %poll-events<incoming> );
    }
    return Any;
  }

  multi method poll() {
    die "cannot poll un unfinalized Poll" unless @!c-items.defined;
    given zmq_poll( @!c-items.as-pointer, self.elems, $!delay)  {
      when -1 { throw-error };
      when  0 { return () };
      default { return
            @!items[  | @!c-items.grep( {  $_.revents +& %poll-events<incoming> },  :k)
                     ]\
                     .map( { $_.do( $_.socket ) } );
              }
    }
  }
}#class

class Poll is export {
  my $doc = q:to/END/;
    A Poll object returned by PollBuilder.finalize

    Methods
      poll()

  END
  #:

  trusts PollBuilder;
  has Poll-impl $!pimpl handles < elems poll >;

  submethod BUILD(:$pimpl ) { $!pimpl = $pimpl; }

  method new  {die "Poll: private constructor";}
  method !create( Poll-impl:D $pimpl)   {return self.bless(:pimpl($pimpl)); }

  method doc {$doc};
}


class PollBuilder is export {
  my $doc = q:to/END/;
    PollBuilder builds a polled set of sockets for zmq_poll

    (Silly) Usage
      my $poll = PollBuilder.new\
        .add(StrPollHandler.new( socket-1, sub ($m) { say "got --$m-- on  socket 1";} ))\
        .add(StrPollHandler.new( socket-2, sub ($m) { say "got --$m-- on  socket 2";} ))\
        .add(socket-3, { False })\
        .delay(500)\
        .finalize;

      1 while $poll.poll;
      say "Done!";

  END
  #:

  has Poll-impl $!pimpl .= new;
  has Bool $!finalized = False;

  method new() {return self.bless()};

  method !check-finalized()  {
    die "PollBuilder: cannot change finalized Poll" if $!finalized;
  }

  method finalize() {
    self!check-finalized();
    die "PollBuilder: you forgot to set a delay" if ! $!pimpl.delay.defined;
    die "PollBuilder: there must be something to poll in a poll" if $!pimpl.elems == 0;
    $!finalized = True;
    $!pimpl.finalize;
    return Poll.CREATE!Poll::create($!pimpl);
  }

  multi method delay( :$block!) { $!pimpl.delay = -1; return self;}
  multi method delay( Int:D $delay where {$delay >= -1 } ) {
    $!pimpl.delay = $delay; return self;
  }

  multi method add( Socket:D $socket, Callable:D $action ) {
    self!check-finalized;
    $!pimpl.add(SocketPollHandler.new($socket, $action ));
    return self;
  }

  multi method add(  PollHandler:D $pr ) {
    self!check-finalized;
    $!pimpl.add($pr) ;
    return self;
  }
  method doc {$doc};
}
