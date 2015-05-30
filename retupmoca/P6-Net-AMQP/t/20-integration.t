use v6;

use Test;

plan 1;

use Net::AMQP;

my $n = Net::AMQP.new;

my $initial-promise = $n.connect;
my $timeout = Promise.in(5);
try await Promise.anyof($initial-promise, $timeout);
unless $initial-promise.status == Kept {
    skip "Unable to connect. Please run RabbitMQ on localhost with default credentials.", 1;
    exit;
}

my $channel-promise = $n.open-channel(1);
my $channel = $channel-promise.result;

my $exchange = $channel.exchange.result;

my $queue = $channel.declare-queue("netamqptest").result;

my $p = Promise.new;

$queue.message-supply.tap({
    is $_.body.decode, "test", 'got sent message';
    $p.keep(1);
});

await $queue.consume;

$exchange.publish(routing-key => 'netamqptest', body => 'test'.encode);

await $p;

my $chan-close-promise = $channel.close("", "");
await $chan-close-promise;

await $n.close("", "");
