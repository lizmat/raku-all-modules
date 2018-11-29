use v6;
use Test;

use LWP::Simple;
use JSON::Tiny;

plan 4;

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

my %headers =
    "Accept"     => "application/json",
    "User-Agent" => "Perl 6",
    "content-type" => "application/json",
;

my $file = 'url.json'.IO.e ?? 'url.json' !! 't/url.json';
my $file-contents = $file.IO.slurp;
my $url = (from-json $file-contents)<url>;
                                  

my $html = LWP::Simple.get($url ~ '/get', %headers);
my %json = from-json $html;

is %json<headers><User-Agent>, "Perl 6", "User agent header is sent by GET";
is %json<headers><Accept>, "application/json", "Accept header is sent by GET";

my %response = from-json LWP::Simple.put($url ~ '/put', %headers, $file-contents );
is (from-json %response<data>)<url>, $url, "Response from PUT is correct";
is %response<headers><Content-Type>, "application/json", "Response case insensitive"

