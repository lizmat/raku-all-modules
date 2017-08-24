use NativeCall;
unit class Net::ZMQ4::Socket is repr('CPointer');

use Net::ZMQ4::Constants;
use Net::ZMQ4::Context;
use Net::ZMQ4::Message;
use Net::ZMQ4::Util;

# ZMQ_EXPORT void *zmq_socket (void *context, int type);
my sub zmq_socket(Net::ZMQ4::Context, int32 --> Net::ZMQ4::Socket) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_close (void *s);
my sub zmq_close(Net::ZMQ4::Socket --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_setsockopt (void *s, int option, const void *optval,
#     size_t optvallen);
my sub zmq_setsockopt_int(Net::ZMQ4::Socket, int32, CArray[int32], int32 --> int32)
    is native('zmq',v5)
    is symbol('zmq_setsockopt')
    { * }
my sub zmq_setsockopt_int64(Net::ZMQ4::Socket, int32, CArray[int64], int32 --> int32)
    is native('zmq',v5)
    is symbol('zmq_setsockopt')
    { * }
my sub zmq_setsockopt_bytes(Net::ZMQ4::Socket, int32, CArray[uint8], int32 --> int32)
    is native('zmq',v5)
    is symbol('zmq_setsockopt')
    { * }
# ZMQ_EXPORT int zmq_getsockopt (void *s, int option, void *optval,
#     size_t *optvallen);
# We have several variants of this function, all with different signatures, to
# circumvent the type-checking (passing a CArray won't work when the sig says
# OpaquePointer). Long-term, this should probably be replaced by better
# functionality for changing pointer types in Zavolaj.
my sub zmq_getsockopt_int(Net::ZMQ4::Socket, int32, CArray[int32], CArray[int32] --> int32)
    is native('zmq',v5)
    is symbol('zmq_getsockopt')
    { * }
my sub zmq_getsockopt_int64(Net::ZMQ4::Socket, int32, CArray[int64], CArray[int32] --> int32)
    is native('zmq',v5)
    is symbol('zmq_getsockopt')
    { * }
my sub zmq_getsockopt_bytes(Net::ZMQ4::Socket, int32, CArray[int8], CArray[int32] --> int32)
    is native('zmq',v5)
    is symbol('zmq_getsockopt')
    { * }
# ZMQ_EXPORT int zmq_bind (void *s, const char *addr);
my sub zmq_bind(Net::ZMQ4::Socket, Str --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_connect (void *s, const char *addr);
my sub zmq_connect(Net::ZMQ4::Socket, Str --> int32) is native('zmq',v5) { * }

# ZMQ_EXPORT int zmq_send (void *s, void *buf, size_t buflen, int flags);
my sub zmq_send(Net::ZMQ4::Socket, CArray[int8], size_t, int32 --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_recv (void *s, void *msg, size_t buflen, int flags);
my sub zmq_recv(Net::ZMQ4::Socket, Net::ZMQ4::Message is rw, int32 --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_send (zmq_msg_t *msg, void *s, int flags);
my sub zmq_msg_send(Net::ZMQ4::Message, Net::ZMQ4::Socket, int32 --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_recv (zmq_msg_t *msg, void *s, int flags);
my sub zmq_msg_recv(Net::ZMQ4::Message is rw, Net::ZMQ4::Socket, int32 --> int32) is native('zmq',v5) { * }

my $lock = Lock.new;

my %opttypes = ZMQ_AFFINITY, int64,
               ZMQ_BACKLOG, int32,
               ZMQ_CONFLATE, int32,
               ZMQ_CONNECT_RID, "bytes",
               ZMQ_CONNECT_TIMEOUT, int32,
               ZMQ_CURVE_PUBLICKEY, "bytes",
               ZMQ_CURVE_SECRETKEY, "bytes",
               ZMQ_CURVE_SERVER, int32,
               ZMQ_CURVE_SERVERKEY, "bytes",
               ZMQ_EVENTS, int32,
               ZMQ_GSSAPI_PLAINTEXT, int32,
               ZMQ_GSSAPI_PRINCIPAL, "bytes",
               ZMQ_GSSAPI_SERVER, int32,
               ZMQ_GSSAPI_SERVICE_PRINCIPAL, "bytes",
               ZMQ_HANDSHAKE_IVL, int32,
               ZMQ_HEARTBEAT_IVL, int32,
               ZMQ_HEARTBEAT_TIMEOUT, int32,
               ZMQ_HEARTBEAT_TTL, int32,
               ZMQ_IDENTITY, "bytes",
               ZMQ_IMMEDIATE, int32,
               ZMQ_INVERT_MATCHING, int32,
               ZMQ_IPV6, int32,
               ZMQ_LINGER, int32,
               ZMQ_MAXMSGSIZE, int64,
               ZMQ_MULTICAST_HOPS, int32,
               ZMQ_MULTICAST_MAXTPDU, int32,
               ZMQ_PLAIN_PASSWORD, "bytes",
               ZMQ_PLAIN_SERVER, int32,
               ZMQ_PLAIN_USERNAME, "bytes",
               ZMQ_PROBE_ROUTER, int32,
               ZMQ_RATE, int32,
               ZMQ_RATE, int64,
               ZMQ_RCVBUF, int64,
               ZMQ_RCVHWM, int32,
               ZMQ_RCVMORE, int32,
               ZMQ_RCVTIMEO, int32,
               ZMQ_RECONNECT_IVL, int32,
               ZMQ_RECONNECT_IVL_MAX, int32,
               ZMQ_RECOVERY_IVL, int64,
               ZMQ_REQ_CORRELATE, int32,
               ZMQ_REQ_RELAXED, int32,
               ZMQ_ROUTER_HANDOVER, int32,
               ZMQ_ROUTER_MANDATORY, int32,
               ZMQ_ROUTER_RAW, int32,
               ZMQ_SNDBUF, int32,
               ZMQ_SNDHWM, int32,
               ZMQ_SNDTIMEO, int32,
               ZMQ_SOCKS_PROXY, "bytes",
               ZMQ_STREAM_NOTIFY, int32,
               ZMQ_SUBSCRIBE, "bytes",
               ZMQ_TCP_KEEPALIVE, int32,
               ZMQ_TCP_KEEPALIVE_CNT, int32,
               ZMQ_TCP_KEEPALIVE_IDLE, int32,
               ZMQ_TCP_KEEPALIVE_INTVL, int32,
               ZMQ_TCP_MAXRT, int32,
               ZMQ_TOS, int32,
               ZMQ_TYPE, int32,
               ZMQ_UNSUBSCRIBE, "bytes",
               ZMQ_USE_FD, int32,
               ZMQ_VMCI_BUFFER_MAX_SIZE, int64,
               ZMQ_VMCI_BUFFER_MIN_SIZE, int64,
               ZMQ_VMCI_BUFFER_SIZE, int64,
               ZMQ_VMCI_CONNECT_TIMEOUT, int32,
               ZMQ_XPUB_MANUAL, int32,
               ZMQ_XPUB_NODROP, int32,
               ZMQ_XPUB_VERBOSE, int32,
               ZMQ_XPUB_VERBOSER, int32,
               ZMQ_XPUB_WELCOME_MSG, "bytes",
               ZMQ_ZAP_DOMAIN, "bytes";

method new(Net::ZMQ4::Context $context, int32 $type, :$linger = 100) {
    $lock.protect(
        {
            my $sock = zmq_socket($context, $type);
            $sock.setopt(ZMQ_LINGER, $linger);
            zmq_die() if not $sock;
            $context-count++;
            return $sock;
        }
    )
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

method close() {
    $lock.protect(
        {
            my $ret = zmq_close(self);
            zmq_die() if $ret != 0;
            CATCH {
                when .errno == 88 {
                    # Double-closing is safe
                }
            }
            $context-count--;
        }
    )
}

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

method sendmore(*@parts) {
    loop (my $i = 0; $i < @parts.elems; $i++) {
        my $part = @parts[$i] ~~ Str ?? @parts[$i].encode !! @parts[$i];
        self.send($part, $i+1 == @parts.elems ?? 0 !! ZMQ_SNDMORE);
    }
}

method receive(int32 $flags = 0) {
    my $msg = Net::ZMQ4::Message.new;
    my $ret = zmq_msg_recv($msg, self, $flags);
    zmq_die() if $ret == -1;
    return $msg;
}

method receivemore() {
    my @parts;
    loop {
        my $msg = self.receive(0);
        @parts.push: $msg.data;
        $msg.close;
        unless $msg.more { return @parts }
    }
}

method getopt($opt) {
    my $optlen = CArray[int32].new;
    my $ret;

    my CArray $val;
    given %opttypes{$opt} {
        when int32 {
            $val = CArray[int32].new;
            $val[0] = 0;
            $optlen[0] = 4;
            $ret = zmq_getsockopt_int(self, $opt, $val, $optlen);
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
    $val[0];
}

method setopt($opt, $value) {
    my size_t $optlen;
    my $ret;

    my CArray $val;
    given %opttypes{$opt} {
        when int32 {
            $val = CArray[int32].new;
            $val[0] = $value;
            $optlen = 4;
            $ret = zmq_setsockopt_int(self, $opt, $val, $optlen);
        }
        when int64 {
            $val = CArray[int64].new;
            $val[0] = $value;
            $optlen = 8;
            $ret = zmq_setsockopt_int64(self, $opt, $val, $optlen);
        }
        when "bytes" {
           $val = CArray[uint8].new;
           # Memory allocation
           $val[$value.elems - 1] = 0;
           die "Send Blob to use $opt" unless $value ~~ Blob;
           for @$value.kv -> $i, $_ { $val[$i] = $_ }
           $ret = zmq_setsockopt_bytes(self, $opt, $val, $value.elems);
        }
        default {
            die "Unknown ZMQ socket option type $opt";
        }
    }

    zmq_die() if $ret != 0;
}
