use Cro::ZeroMQ::Socket::Push;
use Cro::ZeroMQ::Collector;
use Test;

my $pusher = Cro::ZeroMQ::Socket::Push.new(bind => 'tcp://127.0.0.1:2910');

my $client = Cro::ZeroMQ::Collector.pull(connect => 'tcp://127.0.0.1:2910');

my $notifications = $client.Supply.share;

my $complete = Promise.new;

$notifications.tap: -> $_ {
    $complete.keep if $_.body-text eq 'test'
}

$pusher.sinker(
    supply {
        emit Cro::ZeroMQ::Message.new: 'test'
    }
).tap;

await Promise.anyof($complete, Promise.in(2));

is $complete.status, Kept, 'Collector works';

done-testing;
