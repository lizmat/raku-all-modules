use NativeCall;

unit class Net::ZMQ4::Context is repr('CPointer');

use Net::ZMQ4::Util;

# ZMQ_EXPORT void *zmq_ctx_new (void);
my sub zmq_ctx_new() returns Net::ZMQ4::Context is native('zmq', v5) { * }
# ZMQ_EXPORT int zmq_ctx_term (void *context);
my sub zmq_ctx_term(Net::ZMQ4::Context --> int32) is native('zmq', v5) { * }
# ZMQ_EXPORT int zmq_ctx_shutdown (void *context);
my sub zmq_ctx_shutdown(Net::ZMQ4::Context --> int32) is native('zmq', v5) { * }
# ZMQ_EXPORT int zmq_ctx_set (void *context, int option, int optval);
my sub zmq_ctx_set(Net::ZMQ4::Context, int32, int32 --> int32) is native('zmq', v5) { * }
# ZMQ_EXPORT int zmq_ctx_get (void *context, int option);
my sub zmq_ctx_get(Net::ZMQ4::Context, int32 --> int32) is native('zmq', v5) { * }

my $instance;
my $lock;

method new() {
    return $instance if $instance;
    $lock = Lock.new;
    $instance = zmq_ctx_new();
    zmq_die() unless $instance;
    $instance;
}

method get($option) {
    my $value = zmq_ctx_get(self, $option);
    zmq_die if $value < 0;
    $value
}

method set($option, $value) {
    zmq_die if zmq_ctx_set(self, $option, $value) != 0;
}

method term() {
    $lock.protect(
        {
            if $instance && $context-count == 0 {
                zmq_die() if zmq_ctx_term(self) != 0;
                $instance = Nil;
            }
        }
    )
}

method shutdown() {
    zmq_die() if zmq_ctx_shutdown(self) != 0;
}
