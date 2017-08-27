use Cro::ZeroMQ::Internal;
use Net::ZMQ4::Constants;

class Cro::ZeroMQ::Socket::Push does Cro::ZeroMQ::Sink {
    method !type() { ZMQ_PUSH }
}
