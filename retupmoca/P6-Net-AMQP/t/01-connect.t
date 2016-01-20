use v6;

use Test;

plan 4;

use Net::AMQP;

my $n = Net::AMQP.new;

ok 1, 'can create Net::AMQP object';

my $initial-promise = $n.connect;
my $timeout = Promise.in(5);
try await Promise.anyof($initial-promise, $timeout);

unless $initial-promise.status == Kept {
    skip "Unable to connect. Please run RabbitMQ on localhost with default credentials.", 3;
    exit;
}
is $initial-promise.status, Kept, 'Initial connection successful';

my $close-promise = $initial-promise.result;

my $close-promise-new = $n.close("", "");
await $close-promise-new;
is $close-promise-new.status, Kept, 'connection.close success';
is $close-promise.status, Kept, 'Also affects initial connection promise';
