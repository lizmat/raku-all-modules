use v6;
use WebService::Justcoin;

my $API-KEY = "MY_API_KEY";

my $j = WebService::Justcoin.new(
    :api-key($API-KEY),
    :url-post(&ugly-curl-post),
    :url-get(&ugly-curl-get));

say $j.balances()
