use Cro::ZeroMQ::Socket::Pub;
use Cro::ZeroMQ::Socket::Sub;
use Cro::ZeroMQ::Socket::XPub;
use Cro::ZeroMQ::Socket::XSub;
use Cro::ZeroMQ::Message;
use Test;

my $pubSock = Cro::ZeroMQ::Socket::XPub.new(bind => 'tcp://127.0.0.1:5555');
my $subSock = Cro::ZeroMQ::Socket::XSub.new(bind => 'tcp://127.0.0.1:5556');

my $pubSockSupplier = Supplier::Preserving.new;
my $subSockSupplier = Supplier::Preserving.new;

$pubSock.replier.sinker($pubSockSupplier.Supply).tap;
$subSock.replier.sinker($subSockSupplier.Supply).tap;

$subSock.incoming.tap: -> $_ {
    $pubSockSupplier.emit($_);
}

$pubSock.incoming.tap: -> $_ {
    $subSockSupplier.emit(Cro::ZeroMQ::Message.new: parts => .parts);
}

my $p = Promise.new;

my $pub = Cro::ZeroMQ::Socket::Pub.new(connect => 'tcp://127.0.0.1:5556');
my $sub = Cro::ZeroMQ::Socket::Sub.new(connect => 'tcp://127.0.0.1:5555', subscribe => 'a');

$sub.incoming.tap: -> $_ { $p.keep; }

$pub.sinker(
    supply {
        emit Cro::ZeroMQ::Message.new('a', 'test');
    }
).tap;

await Promise.anyof(Promise.in(2), $p);

is $p.status, Kept, 'XPUB/XSUB pair works';

done-testing;
