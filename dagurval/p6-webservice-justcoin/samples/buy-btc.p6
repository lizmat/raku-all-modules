use v6;
use WebService::Justcoin;

constant $API-KEY = "replaceme";
constant $SPEND-AMOUNT = 10.0; # NOK

# OK price for one definition of OK
sub find-ok-price(WebService::Justcoin $j) {

    my %btcnok = $j.markets(:id("BTCNOK"));
    
    die "didn't get BTCNOK market"
        unless %btcnok;

    my Rat $bid = +%btcnok{"bid"};
    my Rat $ask = +%btcnok{"ask"};

    my Rat $ok-price = ($bid + $ask) / 2;
    say "Bid is at $bid, ask is at $ask, our price: $ok-price";

    return $ok-price;
}

my $j = WebService::Justcoin.new(
        :url-get(&ugly-curl-get),
        :url-post(&ugly-curl-post),
        :api-key($API-KEY));

my $ok-price = find-ok-price($j);
my $btcamount = $SPEND-AMOUNT / $ok-price;

say "$SPEND-AMOUNT NOK should buy you $btcamount BTC";

my $order = $j.create-order(
        :market("BTCNOK"),
        :amount($btcamount),
        :type("bid"),
        :price($ok-price));
say "Order created, #", $order{"id"};

say "All orders: ";
say $j.orders().perl;


