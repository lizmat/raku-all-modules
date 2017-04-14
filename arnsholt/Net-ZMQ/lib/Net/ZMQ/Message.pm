use NativeCall;
unit class Net::ZMQ::Message is repr('CStruct');

use Net::ZMQ::Util;

has OpaquePointer $!content;
has int8 $!flags;
has int8 $!vsm_size;

# XXX Hack, hack, hack!
# NativeCall has no way of dealing with flattened arrays yet, so for the time
# being, we just hack around it by embedding 30 byte members instead of a
# 30-byte flattened array.
has int8 $!vsm_data0;
has int8 $!vsm_data1;
has int8 $!vsm_data2;
has int8 $!vsm_data3;
has int8 $!vsm_data4;
has int8 $!vsm_data5;
has int8 $!vsm_data6;
has int8 $!vsm_data7;
has int8 $!vsm_data8;
has int8 $!vsm_data9;
has int8 $!vsm_data10;
has int8 $!vsm_data11;
has int8 $!vsm_data12;
has int8 $!vsm_data13;
has int8 $!vsm_data14;
has int8 $!vsm_data15;
has int8 $!vsm_data16;
has int8 $!vsm_data17;
has int8 $!vsm_data18;
has int8 $!vsm_data19;
has int8 $!vsm_data20;
has int8 $!vsm_data21;
has int8 $!vsm_data22;
has int8 $!vsm_data23;
has int8 $!vsm_data24;
has int8 $!vsm_data25;
has int8 $!vsm_data26;
has int8 $!vsm_data27;
has int8 $!vsm_data28;
has int8 $!vsm_data29;

# ZMQ_EXPORT int zmq_msg_init (zmq_msg_t *msg);
my sub zmq_msg_init(Net::ZMQ::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
my sub zmq_msg_init_size(Net::ZMQ::Message, int64 --> int32) is native('zmq',v5) { * }
# typedef void (zmq_free_fn) (void *data, void *hint);
# ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,
#     size_t size, zmq_free_fn *ffn, void *hint);
my sub zmq_msg_init_data(Net::ZMQ::Message, Str, int32,
    OpaquePointer, OpaquePointer --> int32) is native('zmq',v5) { * }
my sub zmq_msg_init_bytes(Net::ZMQ::Message, CArray[int8], int32,
    OpaquePointer, OpaquePointer --> int32) is native('zmq',v5) is symbol('zmq_msg_init_data') { * }
# ZMQ_EXPORT int zmq_msg_close (zmq_msg_t *msg);
my sub zmq_msg_close(Net::ZMQ::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
my sub zmq_msg_move(Net::ZMQ::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
my sub zmq_msg_copy(Net::ZMQ::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT void *zmq_msg_data (zmq_msg_t *msg);
my sub zmq_msg_data(Net::ZMQ::Message --> CArray[int8]) is native('zmq',v5) { * }
# ZMQ_EXPORT size_t zmq_msg_size (zmq_msg_t *msg);
my sub zmq_msg_size(Net::ZMQ::Message --> int64) is native('zmq',v5) { * }

# TODO: Public interface methods
multi submethod BUILD() {
    my $ret = zmq_msg_init(self);
    zmq_die() if $ret != 0;
}

multi submethod BUILD(Str :$message! is copy) {
    # XXX: This is only going to work with ASCII data
    # XXX: This is going to leak memory without proper lifecycle handling
    explicitly-manage($message); # TODO: Goes away with better blob handling
    my $ret = zmq_msg_init_data(self, $message, $message.chars, OpaquePointer,
        OpaquePointer);
    zmq_die() if $ret != 0;
}

has CArray[uint8] $!data;
multi submethod BUILD(Blob[uint8] :$data!) {
    my CArray[uint8] $msg .= new;
    $msg[$_] = $data[$_] for 0..^$data.elems;
    my $ret = zmq_msg_init_bytes(self, $msg, $msg.elems, OpaquePointer,
        OpaquePointer);
    zmq_die() if $ret != 0;
}

method close() {
    zmq_msg_close(self);
}
submethod DESTROY() {
    zmq_msg_close(self);
}

method data() {
    my $buf = buf8.new;
    my $zmq_data = zmq_msg_data(self);
    for 0..^zmq_msg_size(self) {
        $buf.push: $zmq_data[$_];
    }
    return $buf;
}

method data-str() {
    return $.data.decode;
}

method size() {
    return zmq_msg_size(self);
}

# vim: ft=perl6
