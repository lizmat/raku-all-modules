use Cro::ZeroMQ::Socket::Pub;
use Cro::ZeroMQ::Socket::Push;

class Cro::ZeroMQ::Distributor {
    has $!socket;
    has $!input;

    method BUILD(:$!socket!, :$!input) {}

    method !make($socket) {
        die 'Socket is already created.' if self;
        my $input = Supplier.new;
        $socket.sinker($input.Supply).tap;
        self.bless(:$socket, :$input);
    }

    method push(:$bind) { self!make(Cro::ZeroMQ::Socket::Push.new(:$bind)) }
    method pub(:$bind)  { self!make(Cro::ZeroMQ::Socket::Pub.new(:$bind))  }

    method send($message) { $!input.emit($message) }
}
