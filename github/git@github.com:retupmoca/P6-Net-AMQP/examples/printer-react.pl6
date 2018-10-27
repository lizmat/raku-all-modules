#!perl6

# This does the same as the "printer.pl6" but
# uses the react construct

use v6;

use Net::AMQP;

my $n = Net::AMQP.new;

my $connection = $n.connect.result;

react {
    whenever $n.open-channel(1) -> $channel {

        say "channel";

        whenever $channel.declare-queue("echo") -> $q {

            say "queue";

            $q.consume;

            say "consuming";

            my $body-supply = $q.message-supply.map( -> $v { $v.body.decode }).share;

            whenever $body-supply.grep(/^exit$/) {
                $n.close("", "");
                done();
            }
            whenever $body-supply -> $body {
                say $body;
            }

            say "set-up";
        }
    }
}

await $connection;
