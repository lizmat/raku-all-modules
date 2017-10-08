use WebService::Justcoin;

my $API-KEY = "MY_API_KEY";

my $j = WebService::Justcoin.new(
    :api-key($API-KEY),
    :url-post(&ugly-curl-post),
    :url-get(&ugly-curl-get),
    :url-delete(&ugly-curl-delete));

for $j.orders() -> $o {
    say "Cancelling order $o{'id'}";
    $j.cancel-order($o{'id'});
}
