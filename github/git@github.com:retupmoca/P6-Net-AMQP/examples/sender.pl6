use v6;

use Net::AMQP;

sub MAIN($message){
    my $n = Net::AMQP.new;

    await $n.connect;

    my $channel = $n.open-channel(1).result;

    $channel.exchange.result.publish(routing-key => "echo", body => $message.encode);

    await $n.close("", "");
}
