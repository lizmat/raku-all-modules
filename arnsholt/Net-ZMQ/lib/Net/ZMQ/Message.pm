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
my sub zmq_msg_init(Net::ZMQ::Message --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
my sub zmq_msg_init_size(Net::ZMQ::Message, int --> int) is native('libzmq') { * }
# typedef void (zmq_free_fn) (void *data, void *hint);
# ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,
#     size_t size, zmq_free_fn *ffn, void *hint);
my sub zmq_msg_init_data(Net::ZMQ::Message, Str, int,
    OpaquePointer, OpaquePointer --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_msg_close (zmq_msg_t *msg);
my sub zmq_msg_close(Net::ZMQ::Message --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
my sub zmq_msg_move(Net::ZMQ::Message --> int) is native('libzmq') { * }
# ZMQ_EXPORT int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
my sub zmq_msg_copy(Net::ZMQ::Message --> int) is native('libzmq') { * }
# ZMQ_EXPORT void *zmq_msg_data (zmq_msg_t *msg);
my sub zmq_msg_data(Net::ZMQ::Message --> CArray[int8]) is native('libzmq') { * }
# ZMQ_EXPORT size_t zmq_msg_size (zmq_msg_t *msg);
my sub zmq_msg_size(Net::ZMQ::Message --> int) is native('libzmq') { * }

# TODO: Public interface methods
multi submethod BUILD() {
    my $ret = zmq_msg_init(self);
    zmq_die() if $ret != 0;
}

multi submethod BUILD(:$message!) {
    # XXX: This is only going to work with ASCII data
    # XXX: This is going to leak memory without proper lifecycle handling
    explicitly-manage($message); # TODO: Goes away with better blob handling
    my $ret = zmq_msg_init_data(self, $message, $message.chars, OpaquePointer,
        OpaquePointer);
    zmq_die() if $ret != 0;
}

submethod DESTROY() {
    zmq_msg_close(self);
}

method data() {
    my $buf = buf8.new;
    my $zmq_data = zmq_msg_data(self);
    for 0..^zmq_msg_size(self) {
        $buf ~= buf8.new($zmq_data[$_]);
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
