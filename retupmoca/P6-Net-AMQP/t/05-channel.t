use v6.c;

use Test;

plan 11;

use Net::AMQP;

my $n = Net::AMQP.new;

my $initial-promise = $n.connect;
my $timeout = Promise.in(5);
try await Promise.anyof($initial-promise, $timeout);
unless $initial-promise.status == Kept {
    skip "Unable to connect. Please run RabbitMQ on localhost with default credentials.", 7;
    exit;
}

my $channel-promise = $n.open-channel(1);
await $channel-promise;
is $channel-promise.status, Kept, 'channel.open success';
ok $channel-promise.result ~~ Net::AMQP::Channel, 'value has right class';
my $channel = $channel-promise.result;

is $channel.closed.status , Planned, "the closed Promise remains planned";

my $p;

skip "flow may not be implemented", 2;
if False {
   $timeout = Promise.in(5);
   $p = $channel.flow(0);
   try await Promise.anyof($p, $timeout);
   if $timeout.status == Kept {
      todo("channel.flow(active=false) may not be supported");
   }
   is $p.status, Kept, 'channel.flow(0) success';
   await $p = $channel.flow(1);
   is $p.status, Kept, 'channel.flow(1) success';
}

await $p = $channel.qos(0, 10);
is $p.status, Kept, 'basic.qos success (prefetch limit: 10)';

await $p = $channel.recover(1);
is $p.status, Kept, 'basic.recover success';

my $chan-close-promise = $channel-promise.result.close("", "");
await $chan-close-promise;
is $chan-close-promise.status, Kept, 'channel.close success';
is $channel.closed.status, Kept, "and closed is not Kept";

lives-ok { $chan-close-promise = $channel-promise.result.close("", "") }, "try and close it again";
await $chan-close-promise;
is $chan-close-promise.status, Kept, 'channel.close success (already closed)';

await $n.close("", "");
