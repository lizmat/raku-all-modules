unit module Net::ZMQ::Util;

use NativeCall;

# ZMQ_EXPORT void zmq_version (int *major, int *minor, int *patch);
sub zmq_version(CArray[int32], CArray[int32], CArray[int32]) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_errno (void);
sub zmq_errno(--> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT const char *zmq_strerror (int errnum);
sub zmq_strerror(int32 --> Str) is native('zmq',v5) { * }

class X::ZMQ is Exception {
    has Int $.errno;
    has Str $.strerror;

    method message() {
        return "ZMQ error: $.strerror (code $.errno)";
    }
}

my sub zmq_die() is export {
    my $no = zmq_errno();
    X::ZMQ.new(:errno($no), :strerror(zmq_strerror($no))).throw;
}

# vim: ft=perl6
