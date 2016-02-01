use v6;

use Test;


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

my Int $first-count = 0;

$queue.message-supply.tap({
    is $_.body.decode, "test", 'got sent message';
    $first-count++;
    $p.keep(1);
});

my $ck = "nanananiwo";

is do { await $queue.consume(consumer-tag => $ck) }, $ck, "got back the consumer code we supplied" ;

$exchange.publish(routing-key => 'netamqptest', body => 'test'.encode);

await $p;

await $queue.delete;

my $bind-exchange = $channel.declare-exchange('bind_test', 'direct').result;
my $bind-queue = $channel.declare-queue('', :exclusive).result;
await $bind-queue.bind('bind_test', 'test-key-good');
$bind-queue.consume;
my $body-supply = $bind-queue.message-supply.map( -> $v { $v.body.decode }).share;

my $good-promise = Promise.new;

my Int $second-count = 0;

$body-supply.tap( -> $m {
   is $m, "good-test", "got the thing we expected";
   $second-count++;
   if $good-promise.status ~~ Kept {
      fail "saw more than one message";
   }
   else {
      $good-promise.keep($m);
   }

});

$bind-exchange.publish(routing-key => "test-key-bad", body => "bad-test".encode);
$bind-exchange.publish(routing-key => "test-key-good", body => "good-test".encode);

await $good-promise;
is $good-promise.result, "good-test", "and the promise was kept with what we expected";


await $bind-exchange.delete;

my $multi-exchange = $channel.declare-exchange('multi-test', 'direct').result;

my $multi-queue-one = $channel.declare-queue('', :exclusive).result;
await $multi-queue-one.bind('multi-test', 'multi-test-key-one');
my $ctag-one = await $multi-queue-one.consume;
ok $multi-queue-one.consumer-tag, "and the generated consumer tag got set";
is $multi-queue-one.consumer-tag, $ctag-one, "and it's the same as the one the consume saw";

my $multi-one-promise = Promise.new;
my $multi-one-count = 0;

$multi-queue-one.message-supply.tap({
   $multi-one-count++;
   $multi-one-promise.keep($_.body.decode);
});

my $multi-queue-two = $channel.declare-queue('', :exclusive).result;
await $multi-queue-two.bind('multi-test', 'multi-test-key-two');
my $ctag-two = await $multi-queue-two.consume;
ok $multi-queue-two.consumer-tag, "and the generated consumer tag got set";
is $multi-queue-two.consumer-tag, $ctag-two, "and it's the same as the one the consume saw";

my $multi-two-promise = Promise.new;
my $multi-two-count = 0;

$multi-queue-two.message-supply.tap({
   $multi-two-count++;
   $multi-two-promise.keep($_.body.decode);
});

$multi-exchange.publish(routing-key => "multi-test-key-one", body => "multi-test-one".encode);
$multi-exchange.publish(routing-key => "multi-test-key-two", body => "multi-test-two".encode);
$multi-exchange.publish(routing-key => "multi-test-key-three", body => "multi-test-three".encode);
$multi-exchange.publish(routing-key => "multi-test-key-four", body => "multi-test-four".encode);
await Promise.allof($multi-one-promise, $multi-two-promise);
is $multi-one-promise.result, "multi-test-one", "first tap got we expected";
is $multi-two-promise.result, "multi-test-two", "second tap got we expected";

my $chan-close-promise = $channel.close("", "");
await $chan-close-promise;

await $n.close("", "");

is $first-count, 1, "the first tap only saw one message";
is $second-count, 1, "the second tap only saw one message";
is $multi-one-count, 1, "first multi tap only saw one message";
is $multi-two-count, 1, "second multi tap only saw one message";

done-testing;
