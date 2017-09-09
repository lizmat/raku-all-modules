#!/usr/bin/env perl6

unit module Net::ZMQ::Socket;
use v6;
use NativeCall;

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::V4::Constants;

use Net::ZMQ::Error;
use Net::ZMQ::Common;
use Net::ZMQ::Context;
use Net::ZMQ::SocketOptions;

my constant MAX_RECV_NUMBER = 255;
my constant MAX_SEND_BYTES = 9000;
my constant MAX_RECV_BYTES = 9000;


class Socket does SocketOptions is export {
  my $doc := q:to/END/;

    Class Socket represents a ZMQ Socket.
    Attributes
      context   - the zmq-context; must be supplied to new()
      type      - the ZMQ Socket Type constant;  must be supplied to new()
      last-error - the last zmq error reported
      throw-everything  - when true, all non-fatal errors except EAGAIN (async) throw
      async-fail-throw  - when true, EAGAIN (async) throws; when false EAGAIN returns Any
      max-send-bytes    - largest single part send in bytes
      max-recv-number   - longest charcter string representing an integer number
                          in a single, integer message part
      max-recv-bytes    - bytes threshhold for truncating receive methods

    Methods
    Methods categories - send, receive, option getters and setters, ZMQ socket wrappers, misc
    Methods that do not return a useful value return self on success and Any on failure.
    Send methods return the number of bytes sent or Any.

    Socket Wrapper Methods
        close()
        bind( endpoint  )         ;endpoint must be a string with a valid zmq endpoint
        unbind( ?endpoint )
        connect( endpoint )
        disconnect( ?endpoint )

    Send Methods
          -part sends with SNDMORE flag (incomplete)
          -split causes input to be split and sent in message parts
          -async duh!
        send( Str message, -async, -part )
        send( Int msg-code, -async, -part)
        send( buf8 message-buffer, -async, -part, -max-send-bytes)
        send(Str message, Int split-at -split! -async, -part )
        send(buf8 message-buffer, Int split-at -split! -async, -part )
        //send(Message msg, -part, -async)// circular loading needs to be resolved
        send(buf8 message-buffer, Array splits, -part, -async, -callback, -max-send-bytes)
        send(-empty!, -async, -part )

    Receive Methods
          -bin causes return type to be a byte buffer (buf8) instead of a string
          -int retrieves a single integer message
          -slurp causes all waiting parts of a message to be aseembled and returned as single object
          -truncate truncatesat a maximum byte length
          -async duh!
        receive(-truncate!, -async, -bin)
        receive(-int!, -async, -max-recv-number --> Int)
        receive(-slurp!, -async, -bin)
        receive(-async, -bin)

    Options Methods
        there are option getters and setter for every socket option
        the list of options is in SocketOptions.pm
        every option name creates four legal invocations
          -setters
            option-name(new-value)
            set-option-name(new-value)
          -getters
            option-name()
            get-option-name()
        options can also be accessed explicitly with the ZMQ option Constant.
          - valid Type Objects are Str, buf8 and Int
            get-option(Int opt-contant, Type-Object return-type, Int size )
            set-option((Int opt-contant, new-value, Type-Object type, Int size )


    Misc Methods
        doc(-->Str) ;this

    Comment
      in above signatures, replace - with colon-dollar (this is to please the Atom syntax highlater )

    END
    #:

  has Pointer $.handle;
  has Context $.context;
  has Int   $.type;
  has ZMQError $.last-error;

  has $.throw-everything;
  has $.async-fail-throw;
  has $.max-send-bytes;
  has $.max-recv-number;
  has $.max-recv-bytes;

  my %socket-types = (
                        'pair'          => ZMQ_PAIR
                        , 'publisher'   => ZMQ_PUB
                        , 'subscriber'  => ZMQ_SUB
                        , 'client'      => ZMQ_REQ
                        , 'server'      => ZMQ_REP
                        , 'dealer'      => ZMQ_DEALER
                        , 'router'      => ZMQ_ROUTER
                        , 'pull'        => ZMQ_PULL
                        , 'push'        => ZMQ_PUSH
                        , 'xpub'        => ZMQ_XPUB
                        , 'xsub'        => ZMQ_XSUB
                        , 'stream'      => ZMQ_STREAM
                        );

  method doc {return $doc};

  multi method new($context
              , :$throw-everything = True, :$async-fail-throw
              , :$max-send-bytes, :$max-recv-number, :$max-recv-bytes, *%s ) {
          die "Socket.new: type cannot be determined from {%s}\n"
              ~ "chose one of\n{%socket-types.keys.gist} " if %s.elems != 1;
          my $type = %socket-types{ (keys %s)[0] };
          die "Socket.new: type cannot be determined.\n"
              ~ "chose one of\n{%socket-types.keys.gist}" if !$type.defined;
          return self.bless(:$context, :$type
                        , :$throw-everything, :$async-fail-throw
                        , :$max-send-bytes, :$max-recv-number, :$max-recv-bytes);
    }

  method TWEAK {
      $!handle = zmq_socket( $!context.ctx, $!type);
      throw-error()
            if ! $!handle.defined;
      $!max-send-bytes //= MAX_SEND_BYTES;
      $!max-recv-number //= MAX_RECV_NUMBER;
      $!max-recv-bytes  //= MAX_RECV_BYTES;
    }
  method DESTROY() {
        throw-error() if zmq_close( $!handle ) == -1
                            && $.throw-everything;
    }

  method as-ptr( --> Pointer ) { $!handle }

  method !fail(:$async, --> Bool) {
      my $doc := q:to/END/;
      a place to put failure test and decision about throwing exceptions or other failure
      mechanisms.
      It retuns True unless it throws, allowing for an if condition to chain it to the test
      to produce a fail value. as in

        return Any if  ( result == - i ) && self.fail
        to return False, chain with || !
      END
      #:

        $!last-error = get-error();
        throw-error() if $async && $!last-error.errno == ZMQ_EAGAIN && $.async-fail-throw;
        return True   if $async && $!last-error.errno == ZMQ_EAGAIN;
        throw-error() if $.throw-everything;
        return True;
    }


  method close() {
      return (zmq_close( $!handle ) == 0) || ! self!fail;
    }

  method bind(Str:D $ep) {
      return (zmq_bind($!handle, $ep) == 0) ?? self !! ! ! self!fail;
    }

  method connect(Str:D $ep) {
      return (zmq_connect($!handle, $ep) == 0) ?? self !!  ! self!fail;
    }

  method unbind(Str $ep = self.last-endpoint ) {
      return (zmq_unbind($!handle, $ep) == 0) ?? self  !! ! self!fail;
    }

  method disconnect(Str $ep = self.last-endpoint ) {
      return (zmq_disconnect($!handle, $ep) == 0) ?? self !! ! self!fail;
    }


## SND
    # Str
  multi method send( Str:D $msg, :$async, :$part ) {
      return self.send( buf8.new( | $msg.encode('ISO-8859-1' )), :$async, :$part);
    }

    # int
  multi method send( Int:D $msg-code, :$async, :$part) {
      return self.send("$msg-code", :$async, :$part);
    }

    #buf
  multi method send( buf8:D $buf, :$async, :$part
                    , Int :$max-send-bytes where positive($max-send-bytes)  = $!max-send-bytes ) {
      my $doc := q:to/END/;
      This is the plain vnilla send for a message or message part

      END
      #:

      die "Socket:send : Message too big" if $buf.bytes > $max-send-bytes;

      my $opts = 0;
      $opts += ZMQ_SNDMORE if $part;

      my $result = zmq_send($!handle, $buf, $buf.bytes, $opts);
      return Any if ($result == -1) && self!fail(:$async);

      say "sent $result bytes instead of { $buf.bytes() } !" if $result != $buf.bytes;
      return $result;
    }


  multi method send(Str:D $msg, Int $split-at where positive($split-at) = $!max-send-bytes
                        , :$split!, :$async, :$part ) {
      return self.send(buf8.new( | $msg.encode('ISO-8859-1' )), $split-at, :split, :$async, :$part );
    }


  multi method send(buf8:D $buf, Int $split-at where positive($split-at) = $!max-send-bytes,
                        :$split!, :$async, :$part) {
      my $doc := q:to/END/;
      This splits a message into equal parts and sends it.

      END
      #:

      my $no-more = 0;
      $no-more = ZMQ_SNDMORE if $part;
      $no-more += ZMQ_DONTWAIT if $async;
      my $more = $no-more +| ZMQ_SNDMORE;

      my $sent = 0;
      my $size = $buf.bytes;

      loop ( my $i = 0;$i < $size; $i += $split-at) {
          my $end = ($i + $split-at, $size ).min;
          my $result = zmq_send($!handle
                                , buf8.new( | $buf[$i..$end] )
                                , $end - $i
                                , ($end == $size) ?? $no-more !! $more  );
          return Any if ($result == -1) && self!fail(:$async);
          $sent += $result;
      }
      return $sent;
    }

  multi method send(:$empty!, :$part, :$async ) {
      my $opts = 0;
      $opts += ZMQ_SNDMORE if $part;

      my $result = zmq_send($!handle, buf8, 0, $opts);
      return Any if ($result == -1) && self!fail(:$async);
      return $result;
    }

=begin c
    multi method send(Message $msg, :$part, :$async, :$callback ) {

      return Msg.send($msg, :$part, $async, :$callback);

    }
=end c
=cut

  method sender() {
      my $doc=q:to/END/;
        This method is used internally by other classes.
        Not part of the public API

      END
      #:
      return sub (zmq_msg_t $msg-t, int32 $flags, :$async) {
        my $r = zmq_msg_send($msg-t
                            , $!handle
                            , $flags );
        return Any if ($r == -1) && self!fail(:$async);
        return $r;
      }
    }

=begin c
    multi method send(buf8 $buf, @splits, :$part, :$async, :$callback, :$max-send-bytes = $!max-send-bytes) {
      my $doc := q:to/END/;
      sends a collated message in defined parts with zero-copy.
      $buf  - holds all the message parts sequentially
      @splits -  holds the index where every part begins. if splits are missing,
      the last one is replicated.
      part - allows the parts as an incopmlete message
      callback - specifies a function to use with zero-copy  #ISSUE (does not)
      async - duh!

      this methods uses a c hack to avoid any copying of data in order to benefit from
      the optimizations that rely on the use of zero-copy. The locations in the
      buffer are sent as arguments to ZMQ with the assumption that
      the buffer is an immutable byte array in continguous memory and its reported
      size is accurate. Caveat Empptor!

      The callback has to be threadsafe, and it is not, yet!   #ISSUE

      END
      #:

     die "send(): Message Part too big" if $_ > $!max-send-bytes  for @splits;

      my $no-more = 0;
      $no-more = ZMQ_SNDMORE if $part;
      my $more = $no-more +| ZMQ_SNDMORE;

      my $sending = 0;
      sub callback-f($data, $hint) { say "sending now { --$sending;}" ;}

      my $size = $buf.bytes;
      my $i = 0;
      my $last-split = @splits.elems - 1;
      my $sent = 0;

      while $i < $size {
          my $end = ($i +
                      (($i >= $last-split) ?? @splits[ $last-split ]
                                            !! @splits[ $i ])
                      , $size).min;

          my zmq_msg_t $msg .= new;
          my $r = $callback
                  ?? zmq_msg_init_data_callback($msg, buf8-offset($buf, $i), $end - $i, &callback-f)
                  !! zmq_msg_init_data($msg, buf8-offset($buf, $i), $end - $i);
          throw-error if $r  == -1;
          say "$i -> {$end - $i} : { buf8.new( | $buf[$i..^$end]).decode('ISO-8859-1')}";

          my $result = zmq_msg_send($msg
                        , $!handle
                        , ($end == $size) ?? $no-more !! $more  );
          return Any if ($result == -1) && self!fail(:$async);
          ++$sending;
          $i = $end;
          $sent += $result;
      }
      return $sent;
    }
=end c
=cut

## RECV
   # string
  multi method receive(:$truncate! where uint-bool($truncate)
                            , :$async, :$bin) {
      my $doc := q:to/END/;
      this method uses the vanilla recv of zmq, which truncates messages

      END
      #:
      my $max-recv-bytes = ($truncate.WHAT === Bool) ?? $!max-recv-bytes !! $truncate;
      my int $opts = 0;
      $opts = ZMQ_DONTWAIT if $async;
      my buf8 $buf .= new( (0..^$max-recv-bytes).map( { 0;}    ));

       my int $result = zmq_recv($!handle, $buf, $max-recv-bytes, $opts);

      return Any if ($result == -1) && self!fail(:$async);

      say "message truncated : $result bytes sent 4096 received !" if $result > $max-recv-bytes;
      $result = $max-recv-bytes if $result > $max-recv-bytes;

      return $bin ?? buf8.new( $buf[0..^$result] )
                  !! buf8.new( $buf[0..^$result] ).decode('ISO-8859-1');
    }

    # int
  multi method receive(:$int!, :$async, :$max-recv-number where positive($max-recv-number )
                                                          = $!max-recv-number --> Int) {
      my $doc := q:to/END/;
      this method uses a lower truncation value for integer values. The values are transmitted
      as strings

      END
      #:

      my $r = self.receive(:truncate($max-recv-number), :$async);
      return Any if ! $r.defined;
      return +$r;
    }

    # slurp
  multi method receive(:$slurp!, :$async, :$bin) {
      my $doc := q:to/END/;
      reads and assembles a message from all the parts.

      END
      #:

      my buf8 $msgbuf .= new;
      my $i = 0;
      repeat {
        my $part  = self.receive(:bin, :$async);
        return Any if ! $part.defined;
        
        $msgbuf[ $i++ ] =  $part[ $_]   for 0..^$part.bytes;
      } while self.incomplete;

      return $bin ?? $msgbuf
                  !! $msgbuf.decode('ISO-8859-1');
    }

    #buf
    multi method receive(:$bin, :$async) {
      my $doc := q:to/END/;
      reads one message part without size limits.

      END
      #:

      my zmq_msg_t $msg .= new;
      my int $sz = zmq_msg_init($msg);
      my int $opts = 0;
      $opts = ZMQ_DONTWAIT if $async;


      $sz = zmq_msg_recv( $msg, $!handle, $opts);
      return Any if ($sz == -1) && self!fail( :$async);

      my $data =  zmq_msg_data( $msg );

      my buf8 $buf .= new( (0..^$sz).map( { $data[$_]; } ));

      $sz = zmq_msg_close( $msg);
      return Any if ($sz == -1) && self!fail( :$async);

      return $bin ?? $buf
                    !!  $buf.decode('ISO-8859-1');
    }

    multi method receive(zmq_msg_t @msg-parts, :$async) {
      my Int $cnt = 0;
      repeat {
        my zmq_msg_t $msg .= new;
        my int $sz = zmq_msg_init($msg);
        my int $opts = 0;
        $opts = ZMQ_DONTWAIT if $async;
        $sz = zmq_msg_recv( $msg, $!handle, $opts);
        return Any if ($sz == -1) && self!fail( :$async);
        @msg-parts.push($msg);
        ++$cnt;
      } while self.incomplete;

      return $cnt;
    }

## OPTIONS

### GET
    multi method get-option(int $opt, Int, int $size where positive($size)) {
      my size_t $len =  $size;
      my int64 $value64 = 0;
      my int32 $value32 = 0;
      my $value;
      my $f;
      if $len == 8 {
          $value := $value64;
          $f = &zmq_getsockopt_int64;
      } elsif $len == 4 {
          $value := $value32;
          $f = &zmq_getsockopt_int32;
      } else {
          die "impossible int size! $len";
      }
      return Any if ( -1 == $f($!handle, $opt, $value, $len )) && self!fail;
      return $value;
    }

    multi method get-option(int $opt, Str, int $size ) {
       my buf8 $buf .=new( (0..$size).map( { 0;}  ));
       my size_t $len = $size + 1;

       return Any if ( -1 == zmq_getsockopt($!handle, $opt, $buf, $len )) && self!fail;
       return buf8.new( $buf[0..^--$len] ).decode('utf-8');
    }

    multi method get-option(int $opt, buf8, int $size) {
       my buf8 $buf .=new( (0..^$size).map( { 0;}  ));
       my size_t $len = $size;

       return Any if ( -1 == zmq_getsockopt($!handle, $opt, $buf, $len )) && self!fail;
       return buf8.new( $buf[0..^$len] );
    }


### SET
    multi method set-option(Int $opt, Int $value, Int, int $size where positive($size)) {
      my size_t $len = $size;
      my $array;
      my $f;
      if $len == 8 {
        $array = CArray[int64].new();
        $f = &zmq_setsockopt_int64;
      } elsif $len == 4 {
        $array = CArray[int32].new();
        $f = &zmq_setsockopt_int32;
      } else {
        die "impossible int size! $len";
      }
      $array[0] = $value;
      return Any if (-1 == $f($!handle, $opt, $array, $len )) && self!fail;
      return self;
    }

    multi method set-option(int $opt, Str $value, Str, int $size where positive($size) ) {
      my buf8 $buf = $value.encode('ISO-8859-1');
      my size_t $len = ($buf.bytes, $size).min;

      return Any if  -1 == zmq_setsockopt($!handle, $opt, $buf, $len ) && self!fail;
      return self;
    }

    multi method set-option(int $opt, buf8 $value, buf8, int $size where positive($size)) {
      my size_t $len = Int.min($value.bytes,$size);

      return Any if ( -1 == zmq_setsockopt($!handle, $opt, $value, $len )) && self!fail;
      return self;
    }


### FALLBACK
    method FALLBACK($name, |c($value = Any)) {
      my Str $set-get := $value.defined ?? 'set' !! 'get';
      my Str $method := $name.substr(0,4) eq "$set-get-"  ?? $name.substr(4) !! $name;
      my int $code = self.option( $method, 'code');

      die "Socket: unrecognized option request : { ($name, $value).perl }"
          if ! $code.defined;
      die   "Context: {$value.value ?? 'set' !! 'get'}ting this option not allowed: { ($name, $value).perl }"
          if ! self.option( $method, $set-get );

      my $type = self.option( $method, 'type');
      my int $size = 	self.option( $method, 'size');# // 4;

      return $value // -1 if $code == ZMQ_TEST;

      return $value.defined ?? self.set-option($code, $value, $type, $size)
              !! self.get-option($code, $type, $size);
    }
}
