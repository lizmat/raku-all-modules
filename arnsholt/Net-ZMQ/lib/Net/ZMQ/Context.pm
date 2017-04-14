use NativeCall;
unit class Net::ZMQ::Context is repr('CPointer');

use Net::ZMQ::Util;

# ZMQ_EXPORT void *zmq_init (int io_threads);
my sub zmq_init(int32 --> Net::ZMQ::Context) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_term (void *context);
my sub zmq_term(Net::ZMQ::Context --> int32) is native('zmq',v5) { * }

# TODO: What's a sane default number of threads?
method new(:$threads = 1) {
    my $ctx = zmq_init($threads);
    zmq_die() if not $ctx;
    return $ctx;
}

method terminate() {
    my $ret = zmq_term(self);
    zmq_die() if $ret != 0;
}

# vim: ft=perl6
