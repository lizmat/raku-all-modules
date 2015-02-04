use WebService::Justcoin;

my $API-KEY = "MY_API_KEY";

my $j = WebService::Justcoin.new(
    :api-key($API-KEY),
    :url-post(&ugly-curl-post),
    :url-get(&ugly-curl-get),
    :url-delete(&ugly-curl-delete));


sub MAIN {
    my @orders := $j.orders();
    say @orders;

    say "ID\tMarket\tType\tPrice\tAmount\tRemaining\tMatched\tCreated";
    for @orders -> $o  {
        say (
                $o{'id'},
                $o{'market'},
                $o{'type'},
                $o{'price'},
                $o{'amount'},
                $o{'remaining'},
                $o{'matched'},
                $o{'createdAt'}).join("\t")
    }
}
