
use v6.c;

use Net::AMQP;

module RabbitHelper {

    sub check-rabbit(--> Bool) is export {
        my Bool $rc = False;
        my $n = Net::AMQP.new;
        my $initial-promise = $n.connect;
        my $timeout = Promise.in(5);
        try await Promise.anyof($initial-promise, $timeout);
        if $initial-promise.status == Kept {
            await $n.close("","");
            $rc = True;
        }
        $rc;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
