use v6;

use Test;
use Net::AMQP;


use lib "t/lib";

use RabbitHelper;

plan 2;

if check-rabbit() {

    my $n = Net::AMQP.new;

    await $n.connect;

    my $channel-promise = $n.open-channel(1);
    my $channel = $channel-promise.result;

    my $exchange = $channel.exchange.result;

    my $queue = $channel.declare-queue().result;

    my $p = Promise.new;

    my Int $first-count = 0;

    my $message = (^2048).map({('a' .. 'z', 'A' .. 'Z').flat.pick(1)}).join('');

    my $tap = $queue.message-supply.tap({
        is $_.body.decode, $message, 'got sent message';
        $first-count++;
        $p.keep(1);
        $tap.close;
    });


    await $queue.consume;

    $exchange.publish(routing-key => $queue.name, body => $message.encode);

    await $p;

    await $queue.cancel;

    $p = Promise.new;
    $tap = $queue.message-supply.tap({
        $p.keep(1);
        $tap.close;
    });

    $exchange.publish(routing-key => $queue.name, body => $message.encode);

    await Promise.anyof($p, Promise.in(2));

    ok $p.status ~~ Planned, "didn't get the message after cancel";

    await $queue.delete;

    my $chan-close-promise = $channel.close();
    await $chan-close-promise;

    await $n.close();
}
else {
   skip-rest "Unable to connect. Please run RabbitMQ on localhost with default credentials.";
}

done-testing;
# vim: ft=perl6
