use v6;

use Net::AMQP;

sub MAIN(){
    my $n = Net::AMQP.new;

    await $n.connect;

    my $channel = $n.open-channel(1).result;

    while 1 {
        my $line = prompt("> ");
        $channel.exchange.result.publish(routing-key => "echo", body => $line.encode);
        if $line eq 'exit' {
            await $n.close("", "");
            exit;
        }
    }

}
