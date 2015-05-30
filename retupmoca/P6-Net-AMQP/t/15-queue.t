use v6;

use Test;

plan 2;

use Net::AMQP;

my $n = Net::AMQP.new;

my $initial-promise = $n.connect;
my $timeout = Promise.in(5);
try await Promise.anyof($initial-promise, $timeout);
unless $initial-promise.status == Kept {
    skip "Unable to connect. Please run RabbitMQ on localhost with default credentials.", 2;
    exit;
}

my $channel-promise = $n.open-channel(1);
my $channel = $channel-promise.result;

my $queue-promise = $channel.declare-queue("foobaz");
await $queue-promise;
is $queue-promise.status, Kept, "Can declare new queue";

my $queue-delete-promise = $queue-promise.result.delete;
await $queue-delete-promise;
is $queue-delete-promise.status, Kept, "Can delete queue";

my $chan-close-promise = $channel.close("", "");
await $chan-close-promise;

await $n.close("", "");
