use v6;
use WebService::Justcoin;

constant $API-KEY = "replace me";

my $address = "1Q9nM6xrPdTk59JwWhWfuygWRxa1bXJW8g";
my $amount = 0.001;

my $j = WebService::Justcoin.new(
    :api-key($API-KEY),
    :url-post(&ugly-curl-post),
    :url-get(&ugly-curl-get));

my %resp = $j.create-withdraw-btc(:$address, :$amount);
say %resp.perl;

say "All withdraws: ", $j.withdraws().perl;
