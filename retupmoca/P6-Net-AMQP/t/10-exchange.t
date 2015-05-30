use v6;

use Test;

plan 3;

use Net::AMQP;

my $n = Net::AMQP.new;

my $initial-promise = $n.connect;
my $timeout = Promise.in(5);
try await Promise.anyof($initial-promise, $timeout);
unless $initial-promise.status == Kept {
    skip "Unable to connect. Please run RabbitMQ on localhost with default credentials.", 3;
    exit;
}

my $channel-promise = $n.open-channel(1);
my $channel = $channel-promise.result;

my $exchange-promise = $channel.declare-exchange("amq.direct", "direct", :passive);
await $exchange-promise;
is $exchange-promise.status, Kept, "Can passively declare amq.direct exchange";

$exchange-promise = $channel.declare-exchange("foobaz", "direct");
await $exchange-promise;
is $exchange-promise.status, Kept, "Can declare new exchange";

my $exchange-delete-promise = $exchange-promise.result.delete;
await $exchange-delete-promise;
is $exchange-delete-promise.status, Kept, "Can delete exchange";

my $chan-close-promise = $channel.close("", "");
await $chan-close-promise;

await $n.close("", "");
