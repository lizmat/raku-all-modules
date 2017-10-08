use v6;
use lib 'lib';
use WebService::Justcoin;
use Test;

plan 12;

{ # create-withdraw
    my $j = WebService::Justcoin.new(
        :api-key("neat-key"),
        :url-post(sub ($, %) { create-withdraw-response() }));

    my %resp := $j.create-withdraw-btc(
            address => "1Q9nM6xrPdTk59JwWhWfuygWRxa1bXJW8g",
            amount => 0.01);

    ok %resp{"id"}:exists, "got id from withdraw-btc";
}

{ # withdraws-btc
    my $j = WebService::Justcoin.new(
            :api-key("key"), :url-get(sub ($) { withdraws-response() }));
    my @withdraws = $j.withdraws();
    ok @withdraws.elems > 1, "got more than one withdraw";
    my $w = @withdraws[1];
    ok $w{"currency"}, "has currency";
    ok $w{"amount"}, "has amount";
    ok ?$w{"id"} && $w{"id"} ~~ Int, "has id, int";
    ok $w{"destination"}, "has destination";
    ok ?$w{"created"} && $w{"created"} ~~ DateTime, "has created, is DateTime";
    ok ?$w{"completed"} && $w{"completed"} ~~ DateTime, "has completed, is DateTime";
    ok $w{"method"}, "has method";
    ok $w{"state"}, "has state";
}

{
    # handle non-completed
    my $resp = '[{"created":"2014-04-08T18:06:26.566Z","completed":null}]';
    my $j = WebService::Justcoin.new(:api-key("a"), :url-get(sub ($) { $resp }));
    my @w = $j.withdraws();
    ok @w[0]{"completed"}:exists, "completed exists";
    ok not defined(@w[0]{"completed"}), "completed is not defined";
}

sub create-withdraw-response {
    return '{
            "id": 1234
    }';
}

sub withdraws-response {
q:to/EOR/;
[{"currency":"BTC","amount":"0.00100000","id":23533,"destination":"1Q9nM6xrPdTk59JwWhWfuygWRxa1bXJW8g","created":"2014-04-08T18:06:26.566Z","completed":"2014-04-08T18:06:40.569Z","method":"BTC","state":"completed","error":null},{"currency":"BTC","amount":"0.00200000","id":23534,"destination":"1Q9nM6xrPdTk59JwWhWfuygWRxa1bXJW8g","created":"2014-04-08T18:06:26.566Z","completed":"2014-04-08T18:06:40.569Z","method":"BTC","state":"completed","error":null}]
EOR
}

# vim: ft=perl6
