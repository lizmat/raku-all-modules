use Cro::ZeroMQ::Internal;
use Net::ZMQ4::Constants;

class Cro::ZeroMQ::Socket::Router does Cro::ZeroMQ::Source::Impure does Cro::ZeroMQ::Replyable {
    method !type() { ZMQ_ROUTER }
}
