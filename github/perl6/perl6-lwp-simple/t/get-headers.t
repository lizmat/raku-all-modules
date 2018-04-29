use v6;
use Test;

use LWP::Simple;
use JSON::Tiny;

plan 2;

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

my %headers =
    "Accept"     => "application/json",
    "User-Agent" => "Perl 6",
;

my $file = 'url.json'.IO.e ?? 'url.json' !! 't/url.json';
my $url = (from-json $file.IO.slurp)<url>;

my $html = LWP::Simple.get($url ~ '/get', %headers);
my %json = from-json $html;

is %json<headers><User-Agent>, "Perl 6", "User agent header is sent by GET";
is %json<headers><Accept>, "application/json", "Accept header is sent by GET";
