use v6;

use Test;

plan 6;

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

my $exchange = $exchange-promise.result;

my $return-promise = Promise.new;

my $routing = ('a' .. 'z').pick(8).join ~ $*PID;

$exchange.return-supply.tap( -> $v {
    is $v.arguments[3], $routing, "return-supply got the expected message";
    $return-promise.keep: True;
});


lives-ok { $exchange.publish(routing-key => $routing, body => "Hello, World".encode, :mandatory) }, "publish with mandatory flag to non-existent routing key";

await Promise.anyof( $return-promise, Promise.in(5));

ok $return-promise.status ~~ Kept, "return supply got the message from mandatory";

my $exchange-delete-promise = $exchange-promise.result.delete;
await $exchange-delete-promise;
is $exchange-delete-promise.status, Kept, "Can delete exchange";

my $chan-close-promise = $channel.close("", "");
await $chan-close-promise;

await $n.close("", "");
