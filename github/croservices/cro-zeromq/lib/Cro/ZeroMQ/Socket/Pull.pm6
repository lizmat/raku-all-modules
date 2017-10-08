use Cro::ZeroMQ::Internal;
use Net::ZMQ4::Constants;

class Cro::ZeroMQ::Socket::Pull does Cro::ZeroMQ::Source::Pure {
    method !type() { ZMQ_PULL }
}
