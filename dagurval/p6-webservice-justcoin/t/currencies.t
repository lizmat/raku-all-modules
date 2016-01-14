use v6;
use Test;
use lib 'lib';
use WebService::Justcoin;

plan 5;

my $j := WebService::Justcoin.new(
        :url-get(sub ($url) { currencies-response() }));

my @currencies = $j.currencies();
ok @currencies.elems > 1, "got currencies";

my $c = @currencies[1];
ok $c{'id'}.elems, "has ID";
ok $c{'fiat'}:exists, "has fiat";
ok $c{'fiat'} ~~ Bool, "fiat is bool";
ok $c{'scale'}:exists, "scale exists";

sub currencies-response { q:to/EOR/;
[

    {
        "id": "BTC",
        "fiat": false,
        "scale": 8
    },
    {
        "id": "EUR",
        "fiat": true,
        "scale": 5
    },
    {
        "id": "LTC",
        "fiat": false,
        "scale": 8
    },
    {
        "id": "NOK",
        "fiat": true,
        "scale": 5
    },
    {
        "id": "USD",
        "fiat": true,
        "scale": 5
    },
    {
        "id": "XRP",
        "fiat": false,
        "scale": 6
    }

]
EOR
}

# vim: ft=perl6
