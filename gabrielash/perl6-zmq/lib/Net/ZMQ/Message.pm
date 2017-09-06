#!/usr/bin/env perl6

unit module Net::ZMQ::Message;
use v6;
use NativeCall;

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::V4::Constants;

use Net::ZMQ::Error;
use Net::ZMQ::Common;
use Net::ZMQ::Socket;

class MsgIterator {...}
class MsgBuilder {...}

class Buffer {
  my $doc := q:to/END/;

    class Buffer wraps a byte buffer (buf8)
    ready for use for sending complex multi-part messages fast.
    It is created inside MsgBuilder and consumed by Socket
    and is not designed for end-usage.

    Attributes
      encoding   # not implemented yet

    Methods
      offset(Int segment --> Int)  - returns the position after the end of the segment
      iterator( --> MsgIterator)  - return a segment Iterator
      offset-pointer(Int i --> Pointer) - returns a Pointer to the buffer's byte i location in memory

  END
  #:

  has buf8 $.buffer     is rw = buf8.new;
  has uint @.offsets    is rw;
  has Int  $.next-i     is rw = 0;

  method iterator( --> MsgIterator) {
    return MsgIterator.new(self);
  }

  method bytes( --> Int ) { return $!next-i; }

  method segments(--> Int ) { return @!offsets.elems; }

  method offset(Int:D $i where ^@!offsets.elems --> Int)  {
      return @!offsets[$i];
  }

  method offset-pointer(Int:D $i where ^$!next-i --> Pointer )  {
      return Pointer.new(nativecast(Pointer, $!buffer) + $i);
  }

  method copy( --> Str ) {
     return $!buffer.decode('ISO-8859-1');
  }
}

class MsgIterator {
  my $doc := q:to/END/;

    Forward Iterator over the Message class, returns a series of segments sizes in
    bytes. example

      my $it = $buffer.iterator;
      my $from = 0;
      while $it->has-next {
        $next = $it.next;
        say "segment is from offset $from to { $next - 1 }";
        $from = $next;
      }

  END
  #:

  has Buffer $!buffer handles < segments bytes >;
  has Int $!i;
  has Int $!offset;


  method TWEAK {
    die "MsgIterator needs an instance" unless $!buffer.defined;
    $!i = 0;
    $!offset = Int;
  }

  submethod BUILD( :$buffer ) { $!buffer := $buffer; }

  method new(Buffer $buffer) {
    return self.bless( :$buffer );
  }

  method next( --> Int  ) {
      die "illegal offset" if $!offset > self.bytes;
      return $!offset;
  }

  method has-next( --> Bool)  {
    return False if $!i == self.segments;#$!segments;
    $!offset = $!buffer.offset( $!i++ );
    die "asserting offset not in overflow" unless ($!offset <= self.bytes);
    return True;
  }
}

class Message is export  {
  trusts MsgBuilder;
  my $doc := q:to/END/;

    class Message is an immutable holder of a message
    ready for use in sending multi-part messages using zero-copy.
    It is created by a MsgBuilder.

    Attributes
      encoding   # not implemented yet
      encoding  # not yet implemented

    Methods
        send(Socket, -part, -async, -callback)
        copy( --> Str)
        bytes()
        segments()

  END
  #:

  has Str $.encoding;   # not implemented yet

  has Buffer $!_ handles < copy bytes segments >;

  submethod BUILD(:$_ ) { $!_ = $_; }
  method TWEAK {  }

  method new() { die "Msg: private constructor" };

  method !create( Buffer:D $built) {
    return self.bless( :_($built) );
  }

  method send(Socket:D $socket, :$part, :$async, :$callback where sub( $callback )
                          , :$verbose ) {
    my $doc := q:to/END/;
    sends the assembled message in segments with zero-copy
    part - sets the last part as incopmlete
    callback - specifies a callback function for ZMQ
    async - duh!

    Uses Nativcast Pointer arithmatic to avoid copying of data in order to benefit from
    the optimizations of ZMQ zero-copy. Offsets into the buffer are sent as
    arguments to ZMQ with the assumption that the buffer is an immutable byte
    array in continguous memory. Caveat Emptor!

    The default callback has to be threadsafe, and it is not, yet!   #ISSUE

    END
    #:

        # INVESTIGATE: not sure how zmq_msg_init_data behaves without a callback
        # does it takes ownership and free the memory? Then callbacks are mandatory
        # If callback are used, and we add a reference to msg-t, does this protect
        # against gc as long as the message is in scope? Or does it leak memory?
        # see test 11. with 100000 runs, a local scope callback prevents gc. a
        # callback argument and no callback perform equally well, reclaiming 99.9% at END {}

    my $no-more = 0;
    $no-more = ZMQ_SNDMORE if $part;
    my $more = $no-more +| ZMQ_SNDMORE;

    my $sent = 0;
    my $segments = self.segments;
    my MsgIterator  $it = $!_.iterator;
    my $i = 0;

    while $it.has-next {
      my $end = $it.next;
      my zmq_msg_t $msg-t .= new;
      my $ptr = ($end > $i) ?? $!_.offset-pointer($i)
                            !! Pointer;
      my $r = $callback.defined && $callback.WHAT === Sub
                    ?? zmq_msg_init_data_callback($msg-t,$ptr , $end - $i, $callback)
                    !! zmq_msg_init_data($msg-t, $ptr , $end - $i);
      throw-error if $r  == -1;
      my &sender = $socket.sender;
      $r = sender($msg-t,  (--$segments == 0 ) ?? $no-more !! $more , :$async);
      return Any if ! $r.defined;
      $i = $end;
      $sent += $r;
    }
    return $sent;
  }

}

class MsgBuilder is export {
  my $doc= q:to/END/;
  Class MsgBuilder builds a Message Object that can be used to send complex message
  using zero-copy.

      USAGE example
        my MsgBuilder $builder  .= new;
        my Message $msg =
          $builder.add($envelope)\
                  .add(-empty)\
                  .add($content-1, -max(1024) -newline)\
                  .add($content-2, -max(1024) -newline)\
                  .finalize;
        $msg.send($msg);



  Methods
      new()
      add( Str, -max-part-size -divide-into, -newline --> self)
      add( -empty --> self)
      add( -newline --> self)
      finalize( --> Message)

  ATTN - replace - (dash) with colon-dollar in signatures above
            (subtitution is to please Atom syntax-highlighter)
  END
  #:

  has Str $.encoding;   # not implemented yet

  has Buffer $!_;
  has Bool $!finalized;

  method TWEAK {
    $!_ .= new;
    $!finalized = False;
  }

  method !check-finalized() {
    die "MsgBuilder: cannot change a finalized builder" if $!finalized;
  }

  method finalize (--> Message) {
    self!check-finalized;
    $!finalized = True;
    return Message.CREATE!Message::create($!_);
  }

  multi method add( :$empty! --> MsgBuilder) {
    self!check-finalized;
    $!_.offsets().push($!_.next-i);
    return self;
  }

  multi method add( :$newline! --> MsgBuilder) {
    self!check-finalized;
    $!_.buffer[$!_.next-i++] = 10;
    $!_.offsets().push($!_.next-i);
    return self;
  }

  multi method add( Str:D $part, Int :$max-part-size  where positive($max-part-size)
                                , Int :$divide-into   where positive($divide-into)
                                , :$newline --> MsgBuilder) {
    self!check-finalized;
    my $old-i = $!_.next-i;
    my $max = $max-part-size;
    my $tmp = $part.encode('ISO-8859-1');
    $!_.buffer[$!_.next-i++] = $tmp[$_] for 0..^$tmp.bytes;
    $!_.buffer[$!_.next-i++] = 10 if $newline;

    if $divide-into {
      $max = ($!_.next-i - $old-i) div $divide-into;
    }

    if $max {
      $!_.offsets().push($_)
          if ($_ - $old-i) %% $max
            for $old-i^..^$!_.next-i;
    }

    $!_.offsets.push($!_.next-i);
    return self;
  }


}
