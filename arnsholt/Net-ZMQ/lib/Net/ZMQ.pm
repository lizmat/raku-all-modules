unit module Net::ZMQ;

use NativeCall;

use Net::ZMQ::Constants;
use Net::ZMQ::Context;
use Net::ZMQ::Message;
use Net::ZMQ::Pollitem;
use Net::ZMQ::Socket;
use Net::ZMQ::Util;
use Net::ZMQ::Poll;

# ZMQ_EXPORT int zmq_device (int device, void * insocket, void* outsocket);
my sub zmq_device(int, Net::ZMQ::Socket, Net::ZMQ::Socket --> int) is native('libzmq') { * }

multi sub device(Net::ZMQ::Socket $in, Net::ZMQ::Socket $out, Bool :queue($)) is export {
    # TODO: Check for errors and turn them into exceptions.
    zmq_device(ZMQ_QUEUE, $in, $out);
}

# vim: ft=perl6
