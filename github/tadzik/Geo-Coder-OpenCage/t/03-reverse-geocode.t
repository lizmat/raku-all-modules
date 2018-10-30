use v6;
use Test;
use Geo::Coder::OpenCage;

plan 12;
my $api-key = %*ENV<GEO_CODER_OPENCAGE_API_KEY>;
unless $api-key {
    skip-rest "Set GEO_CODER_OPENCAGE_API_KEY environment variable "
            ~ "to run this test";
    exit;
}
my $client = Geo::Coder::OpenCage.new: :$api-key;

my @tests =
    # Basics
    {
        input => {
            lat => -32.5980702,
            lng => 149.5886383
        },
        output => "Mudgee",
    },

    # Encoding
    {
        input => {
            lat => 51.9625101,
            lng => 7.6251879,
        },
        output => "Münster",
    },

    # language
    {
        input => {
            lat => 35.6823815,
            lng => 139.7530053,
            language => "jp",
        },
        output => "東京都",
    };

for @tests -> $t {
    my $location = $t<input><lat> ~ ", " ~ $t<input><lng>;
    ok $location, "Trying to geocode '$location'";

    my $resp = $client.reverse-geocode(
        $t<input><lat>:delete, $t<input><lng>:delete, |$t<input>);
    ok $resp.status.ok, '... got a sane response';
    my $num-results = $resp.results.elems;
    ok $num-results > 0, "... got at least one ($num-results) results";

    my $good-results = 0;
    my $expected = $t<output>;
    for $resp.results -> $r {
        $good-results++ if any($r.components.values) ~~ /^$expected»/
    }
    ok $good-results, "... got at least one ($good-results) results "
                    ~ "where we expect them to be";
}
