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
    "User-Agent" => "Perl 6...",
;

my $html = LWP::Simple.delete('http://httpbin.org/delete', %headers);
my %json = from-json $html;

is %json<headers><User-Agent>, "Perl 6...", "User agent header is sent by DELETE";
is %json<headers><Accept>, "application/json", "Accept header is sent by DELETE";
