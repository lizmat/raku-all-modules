use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::Socket-Connection-Linux:ver<0.1.1>:auth<cpan:JMASLAK>
    does StrictClass;

use NativeCall;

enum States (
    SOCKET_CLOSED => 0;
    SOCKET_OPEN   => 1;
);

has UInt:D   $.my-port     is required;
has Str:D    $.my-host     is required;
has Int:D    $.peer-family is required;
has UInt:D   $.peer-port   is required where ^(2¹⁶);
has Str:D    $.peer-host   is required;
has Int:D    $.socket-fd   is required;
has Lock:D   $!lock        = Lock.new;
has Channel  $!out-channel;
has States:D $.state       is rw = SOCKET_OPEN;

# Aliases for socket-(port|host)
method socket-host { return $.my-host }
method socket-port { return $.my-port }

# write(int fd, const void *buf, size_t count)
sub native-write(int32, Pointer, int32 -->int32) is native is symbol('write') {*}

method write(buf8:D $buffer -->Nil) {
    if $!state ≠ SOCKET_OPEN { die "Socket in wrong state" }

    my $rv = native-write($!socket-fd, nativecast(Pointer, $buffer), $buffer.bytes);
    if $rv ≠ $buffer {
        self.close if $!state ≠ SOCKET_CLOSED;
    }
}

method say(Str:D $str) {
    if $!state ≠ SOCKET_OPEN { die "Socket in wrong state" }

    self.print("$str\n");
}

method print(Str:D $str) {
    if $!state ≠ SOCKET_OPEN { die "Socket in wrong state" }

    self.write( buf8.new( $str.encode(:encoding('ascii')) ) );
}

# recv(int fd, void *buf, size_t len, int flags)
sub native-recv(int32, buf8 is rw, int32, int32 -->int32) is native is symbol('recv') {*}

method recv(-->buf8) {
    if $!state ≠ SOCKET_OPEN { die "Socket in wrong state" }

    my $buf = buf8.new( 0 xx (2¹⁶) );
    my $rv = native-recv($!socket-fd, $buf, $buf.bytes, 0);

    if $rv < 0  {
        self.close if $!state ≠ SOCKET_CLOSED;
        die("recv returned an error")
    }
    if $rv == 0 { return buf8.new; }
    
    return $buf.subbuf(0..^($rv));
}

# Supply
method Supply(-->Supply:D) {
    if $!state ≠ SOCKET_OPEN { die "Socket in wrong state" }

    my $supplier = Supplier::Preserving.new;
    my $supply   = $supplier.Supply;

    start {
        while $!state == SOCKET_OPEN {
            my $buf = self.recv;
            if $buf.bytes == 0 {
                self.close;
            } else {
                $supplier.emit($buf);
            }
        }
        $supplier.done;

        CATCH {
            default {
                $supplier.done;
                self.close if $!state ≠ SOCKET_CLOSED;
            }
        }
    }

    return $supply;
}

# Output (Buffered)
method buffered-send(buf8:D $buffer -->Nil) {
    if $!state ≠ SOCKET_OPEN { die "Socket in wrong state" }

    $!lock.protect: {
        if ! $!out-channel.defined {
            $!out-channel = Channel.new;
            start loop {
                my $to-send = $!out-channel.receive;
                self.write($to-send);
            }
        }
    }

    $!out-channel.send($buffer);
}

# close(int)
sub native-close(int32 -->int32) is native is symbol('close') {*}

method close(-->Nil) {
    if $!state ≠ SOCKET_OPEN { return; }

    my $rv = native-close($!socket-fd);
    if $rv { die("close failed") }

    $!state = SOCKET_CLOSED;
}

submethod DESTROY {
    if self.state ≠ SOCKET_CLOSED { self.close }
    CATCH {
        default { }
    }
}

