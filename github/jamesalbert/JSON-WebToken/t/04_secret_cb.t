use v6;
use Test;
use JSON::WebToken;

plan 2;

my $secret_map = {
    joe   => "joe's secret",
    smith => "smith's secret",
};

sub test_secret_cb {
    my (%opts) = @_;
    my ($claims, $desc) = %opts{qw/claims desc/};
    my $secret    = $secret_map{$claims{'iss'}};
    my $secret_cb = sub {
        my ($header, $claims) = @_;
        $secret_map{$claims{'iss'}};
    };
    say $claims;
    subtest {
        my $jwt  = encode_jwt $claims, $secret;
        my $data = decode_jwt $jwt, $secret_cb;
        is-deeply $data, $claims;
    };
}

test_secret_cb({
    claims  => {
        iss => 'joe',
        exp => time + 30,
        foo => 'bar',
    },
    desc => 'joe',
});

test_secret_cb({
    claims => {
        iss => 'smith',
        exp => time + 30,
        foo => 'bar',
    },
    desc => 'smith',
});
