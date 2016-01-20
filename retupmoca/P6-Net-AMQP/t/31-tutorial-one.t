#!perl6

use v6.c;

use Test;
use Net::AMQP;

plan 2;

{
    my $n = Net::AMQP.new;
    my $initial-promise = $n.connect;
    my $timeout = Promise.in(5);
    try await Promise.anyof($initial-promise, $timeout);
    unless $initial-promise.status == Kept {
        skip "Unable to connect. Please run RabbitMQ on localhost with default credentials.", 2;
        exit;
    }
    await $n.close("","");
}

my Promise $start-promise = Promise.new;

# This tests for the behaviour in the RabbitMQ tutorial one
# By way of a full up integrated test.
# This differs in that we don't close the connection
my $p = start {
    my $n = Net::AMQP.new;
    my $connection = $n.connect.result;
    my Str $ret = "FAIL";
    react {
        whenever $n.open-channel(1) -> $channel {
            whenever $channel.declare-queue("hello") -> $q {
                $q.consume;
                $start-promise.keep([$n, $connection]);
                whenever $q.message-supply.map( -> $v { $v.body.decode }) -> $message {
                    $ret = $message;
                    done();
                }
            }
        }
    }
    $ret;
}

# wait for the receiver to start u
my ( $receiver, $receiver-promise) =  await $start-promise;
{
    my $n = Net::AMQP.new;
    my $con =  await $n.connect;
    my $channel = $n.open-channel(1).result;;
    $channel.exchange.result.publish(routing-key => "hello", body => "Hello, World".encode);
    await $n.close("", "");
    await $con;
}

await $p;
is $p.status, Kept, "receiver status Kept";
is $p.result, "Hello, World", "and it got our message";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
