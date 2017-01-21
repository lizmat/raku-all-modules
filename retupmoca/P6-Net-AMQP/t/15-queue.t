use v6.c;

use Test;

plan 10;

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
isa-ok $queue-promise.result, Net::AMQP::Queue, "and there is a queue back";

my $queue-delete-promise = $queue-promise.result.delete;
await $queue-delete-promise;
is $queue-delete-promise.status, Kept, "Can delete queue";

$queue-promise = $channel.declare-queue("");
await $queue-promise;
is $queue-promise.status, Kept, "Can declare new queue without an explicit name";
ok $queue-promise.result.name, "and it has the auto-generated name now ({ $queue-promise.result.name })";

$queue-delete-promise = $queue-promise.result.delete;
await $queue-delete-promise;
is $queue-delete-promise.status, Kept, "Can delete that queue";

# declare-queue with no name
lives-ok { $queue-promise = $channel.declare-queue() }, "declare-queue with no name";
await $queue-promise;
is $queue-promise.status, Kept, "Can declare new queue without an explicit name";
ok $queue-promise.result.name, "and it has the auto-generated name now ({ $queue-promise.result.name })";

$queue-delete-promise = $queue-promise.result.delete;
await $queue-delete-promise;
is $queue-delete-promise.status, Kept, "Can delete that queue";

my $chan-close-promise = $channel.close("", "");
await $chan-close-promise;

await $n.close("", "");


# vim: expandtab shiftwidth=4 ft=perl6
