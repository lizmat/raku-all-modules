use v6;
use Test;
use lib 'lib';
use WebService::Justcoin;

plan 17;

my $j := WebService::Justcoin.new(:url-get(sub ($) { }));
dies-ok { $j.orders() }, "method requires API key";

# no orders in book
{
    $j := WebService::Justcoin.new(
        :api-key("some-nice-key"),
        :url-get(sub ($) { no-orders-response() }));
    my @orders = $j.orders();
    ok @orders.elems == 0, "no orders";
}

# orders
{
    $j := WebService::Justcoin.new(
        :api-key("some-nice-key"),
        :url-get(sub ($) { orders-response() }));

    my @orders = $j.orders();
    ok @orders.elems > 1, "got orders";

    my $o = @orders[1];
    ok $o{'id'}:exists, "id exists";
    ok $o{'market'}:exists, "market exists";
    ok $o{"type"}:exists, "type exists";
    ok $o{"price"}:exists, "price exists";
    ok $o{"amount"}:exists, "amount exists";
    ok $o{"remaining"}:exists, "remaining exists";
    ok $o{"matched"}:exists, "matched exists";
    ok $o{"cancelled"}:exists, "cancelled exists";
    ok $o{"createdAt"}:exists, "createdAt exists";
    ok $o{"createdAt"} ~~ DateTime, "createdAt is a DateTime object"

}

# create-order
{
    $j := WebService::Justcoin.new(
        :api-key("some-nice-key"),
        :url-post(sub ($, %) { create-orders-response }));

    my $res = $j.create-order(:market("BTCNOK"), :type("bid"), :price(10.0), :amount(0.01));
    ok $res{'id'}:exists, "got id back";

    dies-ok { $j.create-order(:market("BTCNOK", :type("invalid"), :price(10000), :amount(1.0))) }, "invalid type";

    # market price
    $res = $j.create-order(:market("BTCNOK"), :type("ask"), :amount(0.1));
    ok $res{"id"}:exists;
}

# cancel-order
{
    $j := WebService::Justcoin.new(
        :api-key("some-nice-key"),
        :url-delete(sub ($) { }));
    lives-ok { $j.cancel-order(1234); }, "lives running cancel-order";
}

sub no-orders-response { "[ ]" }
sub orders-response {
        q:to/EOR/;
[
    {
        "id": 130,
        "market": "BTCLTC",
        "type": "bid",
        "price": "40.000",
        "amount": "0.10000",
        "remaining": "0.09005",
        "matched": "0.00995",
        "cancelled": "0.00000",
        "createdAt": "2014-02-03T12:04:24.076Z"
    },
    {
        "id": 129,
        "market": "BTCXRP",
        "type": "bid",
        "price": "10000.000",
        "amount": "0.00100",
        "remaining": "0.00001",
        "matched": "0.00099",
        "cancelled": "0.00000",
        "createdAt": "2014-02-03T12:04:07.273Z"
    }
]
EOR

}

sub create-orders-response {
    return '{
            "id": 1234
    }';
}


# vim: ft=perl6
