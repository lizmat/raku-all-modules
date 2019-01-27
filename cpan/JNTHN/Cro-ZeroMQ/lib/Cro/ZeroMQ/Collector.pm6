use Cro::ZeroMQ::Socket::Pull;
use Cro::ZeroMQ::Socket::Sub;

class Cro::ZeroMQ::Collector {
    has $!socket;

    method Supply() {
        $!socket.incoming;
    }

    method BUILD(:$!socket!) {}

    method sub(:$connect, :$bind, :$high-water-mark,
               :$subscribe, :$unsubscribe) {
        die 'Already initialized' if self;
        my $socket = Cro::ZeroMQ::Socket::Sub.new(
            :$connect, :$bind, :$high-water-mark,
            :$subscribe, :$unsubscribe);
        self.bless(:$socket);
    }

    method pull(:$connect, :$bind, :$high-water-mark) {
        die 'Already initialized' if self;
        my $socket = Cro::ZeroMQ::Socket::Pull.new(
            :$connect, :$bind, :$high-water-mark);
        self.bless(:$socket);
    }
}
