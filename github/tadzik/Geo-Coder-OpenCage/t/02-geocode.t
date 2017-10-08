use v6;
use Test;
use Geo::Coder::OpenCage;

plan 24;
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
            location => "Mudgee, Australia",
        },
        output => [ -32.5980702, 149.5886383 ],
    },
    {
        input => {
            location => "EC1M 5RF",
        },
        output => [ 51.5201666,  -0.0985142 ],
    },

    # Encoding in request
    {
        input => {
            location => "Münster",
        },
        output => [ 51.9625101,   7.6251879 ],
    },

    # Encoding in response
    {
        input => {
            location => "Donostia",
        },
        output => [ 43.300836,  -1.9809529 ],
    },

    # language
    {
        input => {
            location => "東京都",
            language => "jp",
        },
        output => [ 35.6823815, 139.7530053 ],
    },

    # country
    {
        input => {
            location => "Madrid",
            country => "esp",
        },
        output => [ 40.383333, -3.716667 ],
    };

for @tests -> $t {
    my $place = $t<input><location>:delete;
    ok $place, "Trying to geocode '$place'";
    my $resp = $client.geocode($place, |$t<input>);
    ok $resp.status.ok, '... got a sane response';
    my $num-results = $resp.results.elems;
    ok $num-results > 0, "... got at least one ($num-results) results";

    sub close-enough($x, $y) { abs($x - $y) < 0.05 }

    my $good-results = 0;
    for $resp.results -> $r {
        $good-results++ if close-enough($r.geometry.lat, $t<output>[0])
                       and close-enough($r.geometry.lng, $t<output>[1]);
    }
    ok $good-results, "... got at least one ($good-results) results "
                    ~ "where we expect them to be";
}
