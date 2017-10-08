use v6;

use Net::AMQP;

my $n = Net::AMQP.new;

my $connection = $n.connect.result;

say 'connected';

my $channel = $n.open-channel(1).result;

say 'channel';

my $q = $channel.declare-queue('echo').result;

say 'queue';

$q.message-supply.tap({
    say 'Got message!';
    say $_.body.decode;
    if $_.body.decode eq 'exit' {
        $n.close("", "");
    }
});

say 'set up';

$q.consume;

say 'consuming';

await $connection;
