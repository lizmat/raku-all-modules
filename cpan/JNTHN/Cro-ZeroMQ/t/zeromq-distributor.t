use Cro::ZeroMQ::Message;
use Cro::ZeroMQ::Distributor;
use Cro::ZeroMQ::Socket::Pull;
use Cro::ZeroMQ::Socket::Sub;
use Test;

# Push-Pull
my $complete = Promise.new;
my $receiver = Cro::ZeroMQ::Socket::Pull.new(connect => 'tcp://127.0.0.1:3673');
my $client = Cro::ZeroMQ::Distributor.push(bind => 'tcp://127.0.0.1:3673');

my $tap = $receiver.incoming.tap: -> $_ {
    $complete.keep if .body-text eq 'test';
}

$client.send(Cro::ZeroMQ::Message.new('test'));

await Promise.anyof($complete, Promise.in(1));

is $complete.status, Kept, 'Push sender works';

$tap.close;

$complete = Promise.new;
$receiver = Cro::ZeroMQ::Socket::Sub.new(connect => 'tcp://127.0.0.1:3232', subscribe => '');
$client = Cro::ZeroMQ::Distributor.pub(bind => 'tcp://127.0.0.1:3232');

$tap = $receiver.incoming.tap: -> $_ {
    $complete.keep if .body-text eq 'test';
}

$client.send(Cro::ZeroMQ::Message.new('test'));

await Promise.anyof($complete, Promise.in(1));

is $complete.status, Kept, 'Pub sender works';

$tap.close;

dies-ok {
    my $client = Cro::ZeroMQ::Distributor.push(bind => 'tcp://127.0.0.1:4242');
    $client.push(bind => 'tcp://127.0.0.1:4243');
}, 'Distributor cannot be re-created';

done-testing;
