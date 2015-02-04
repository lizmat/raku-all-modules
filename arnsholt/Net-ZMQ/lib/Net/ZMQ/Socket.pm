use NativeCall;
class Net::ZMQ::Socket is repr('CPointer');

use Net::ZMQ::Constants;
use Net::ZMQ::Context;
use Net::ZMQ::Message;
use Net::ZMQ::Util;

# ZMQ_EXPORT void *zmq_socket (void *context, int type);
my sub zmq_socket(Net::ZMQ::Context, int --> Net::ZMQ::Socket) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_close (void *s);
my sub zmq_close(Net::ZMQ::Socket --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_setsockopt (void *s, int option, const void *optval,
#     size_t optvallen); 
my sub zmq_setsockopt_int(Net::ZMQ::Socket, int, CArray[int], int --> int)
    is native('libzmq')
    is symbol('zmq_setsockopt')
    { * }
my sub zmq_setsockopt_int32(Net::ZMQ::Socket, int, CArray[int32], int --> int)
    is native('libzmq')
    is symbol('zmq_setsockopt')
    { * }
my sub zmq_setsockopt_int64(Net::ZMQ::Socket, int, CArray[int64], int --> int)
    is native('libzmq')
    is symbol('zmq_setsockopt')
    { * }
my sub zmq_setsockopt_bytes(Net::ZMQ::Socket, int, CArray[int8], int --> int)
    is native('libzmq')
    is symbol('zmq_setsockopt')
    { * }
# ZMQ_EXPORT int zmq_getsockopt (void *s, int option, void *optval,
#     size_t *optvallen);
# We have several variants of this function, all with different signatures, to
# circumvent the type-checking (passing a CArray won't work when the sig says
# OpaquePointer). Long-term, this should probably be replaced by better
# functionality for changing pointer types in Zavolaj.
my sub zmq_getsockopt_int(Net::ZMQ::Socket, int, CArray[int], CArray[int] --> int)
    is native('libzmq')
    is symbol('zmq_getsockopt')
    { * }
my sub zmq_getsockopt_int32(Net::ZMQ::Socket, int, CArray[int32], CArray[int] --> int)
    is native('libzmq')
    is symbol('zmq_getsockopt')
    { * }
my sub zmq_getsockopt_int64(Net::ZMQ::Socket, int, CArray[int64], CArray[int] --> int)
    is native('libzmq')
    is symbol('zmq_getsockopt')
    { * }
my sub zmq_getsockopt_bytes(Net::ZMQ::Socket, int, CArray[int8], CArray[int] --> int)
    is native('libzmq')
    is symbol('zmq_getsockopt')
    { * }
# ZMQ_EXPORT int zmq_bind (void *s, const char *addr);
my sub zmq_bind(Net::ZMQ::Socket, Str --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_connect (void *s, const char *addr);
my sub zmq_connect(Net::ZMQ::Socket, Str --> int) is native('libzmq') { * }

# ZMQ_EXPORT int zmq_send (void *s, void *buf, size_t buflen, int flags);
my sub zmq_send(Net::ZMQ::Socket, CArray[uint8], int, int --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_recv (void *s, void *msg, size_t buflen, int flags);
my sub zmq_recv(Net::ZMQ::Socket, CArray[uint8], int --> int) is native('libzmq') { * }

# ZMQ_EXPORT int zmq_send_msg (void *s, zmq_msg_t *msg, int flags);
my sub zmq_sendmsg(Net::ZMQ::Socket, Net::ZMQ::Message, int --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_recv_msg (void *s, zmq_msg_t *msg, int flags);
my sub zmq_recvmsg(Net::ZMQ::Socket, Net::ZMQ::Message, int --> int) is native('libzmq') { * }

my %opttypes = ZMQ_BACKLOG, int,
               ZMQ_TYPE, int,
               ZMQ_LINGER, int,
               ZMQ_RECONNECT_IVL, int,
               ZMQ_RECONNECT_IVL_MAX, int,

               ZMQ_AFFINITY, int64,
               ZMQ_RCVMORE, int64,
               ZMQ_HWM, int64,
               ZMQ_SWAP, int64,
               ZMQ_RATE, int64,
               ZMQ_RECOVERY_IVL, int64,
               ZMQ_RECOVERY_IVL_MSEC, int64,
               ZMQ_MCAST_LOOP, int64,
               ZMQ_SNDBUF, int64,
               ZMQ_RCVBUF, int64,

               ZMQ_IDENTITY, "bytes",
               ZMQ_EVENTS, int32;

method new(Net::ZMQ::Context $context, int $type) {
    my $sock = zmq_socket($context, $type);
    zmq_die() if not $sock;
    return $sock;
}

method bind(Str $address) {
    my $ret = zmq_bind(self, $address);
    zmq_die() if $ret != 0;
}

# TODO: setsockopt/getsockopt. Best way to expose them might be separate
# accessors for each property?

method connect(Str $address) {
    my $ret = zmq_connect(self, $address);
    zmq_die() if $ret != 0;
}

# TODO: There's probably a more Perlish way to handle the flags.
multi method send(Str $message, $flags = 0) {
    return self.send($message.encode("utf8"), $flags);
}

multi method send(Blob $buf, $flags = 0) {
    my $carr = CArray[int8].new;
    for $buf.list.kv -> $idx, $val { $carr[$idx] = $val; }
    my $ret = zmq_send(self, $carr, $buf.elems, $flags);
    zmq_die if $ret == -1;
    return $ret;
}

multi method send(Net::ZMQ::Message $message, $flags = 0) {
    my $ret = zmq_sendmsg(self, $message, $flags);
    zmq_die() if $ret == -1;
    return $ret;
}

method receive(int $flags) {
    my $msg = Net::ZMQ::Message.new;
    my $ret = zmq_recvmsg(self, $msg, $flags);
    zmq_die() if $ret == -1;
    return $msg;
}

method getopt($opt) {
    my CArray[int] $optlen .= new;
    my $ret;

    my CArray $val;
    given %opttypes{$opt} {
        when int {
            $val = CArray[int].new;
            $val[0] = 0;
            $optlen[0] = 4;
            $ret = zmq_getsockopt_int(self, $opt, $val, $optlen);
        }
        when int32 {
            $val = CArray[int32].new;
            $val[0] = 0;
            $optlen[0] = 4;
            $ret = zmq_getsockopt_int32(self, $opt, $val, $optlen);
        }
        when int64 {
            $val = CArray[int64].new;
            $val[0] = 0;
            $optlen[0] = 8;
            $ret = zmq_getsockopt_int64(self, $opt, $val, $optlen);
        }
        # TODO: bytes
        #when "bytes" {
        #    $val = CArray[int8].new;
        #    $val[0] = int8;
        #    $ret = zmq_getsockopt_int8(self, $opt, $val, $optlen);
        #}
        default {
            die "Unknown ZMQ socket option type $opt";
        }
    }

    zmq_die() if $ret != 0;
    return $val[0];
}

method setopt($opt, $value) {
    my CArray[int] $optlen .= new;
    my $ret;

    my CArray $val;
    given %opttypes{$opt} {
        when int {
            $val = CArray[int].new;
            $val[0] = $value;
            $optlen[0] = 4;
            $ret = zmq_setsockopt_int(self, $opt, $val, $optlen);
        }
        when int32 {
            $val = CArray[int32].new;
            $val[0] = $value;
            $optlen[0] = 4;
            $ret = zmq_setsockopt_int32(self, $opt, $val, $optlen);
        }
        when int64 {
            $val = CArray[int64].new;
            $val[0] = $value;
            $optlen[0] = 8;
            $ret = zmq_setsockopt_int64(self, $opt, $val, $optlen);
        }
        # TODO: bytes
        #when "bytes" {
        #    $val = CArray[int8].new;
        #    $val[0] = $value;
        #    $ret = zmq_setsockopt_int8(self, $opt, $val, $optlen);
        #}
        default {
            die "Unknown ZMQ socket option type $opt";
        }
    }

    zmq_die() if $ret != 0;
    return;
}

# ZMQ_EXPORT int zmq_device (int device, void * insocket, void* outsocket);
my sub zmq_device(int, Net::ZMQ::Socket, Net::ZMQ::Socket --> int) is native('libzmq') { * }

# vim: ft=perl6
