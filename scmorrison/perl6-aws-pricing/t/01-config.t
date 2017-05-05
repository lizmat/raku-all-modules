use v6;
use Test;
use lib 'lib';
use AWS::Pricing;

plan 3;

# config
my $tmp_cache_path = $*TMPDIR ~ "/aws-pricing-config-test";

my $config = AWS::Pricing::config(
    api_version => 'v1.0',
    cache_path  => $tmp_cache_path,
    refresh     => True
);

is $config<api_version>, 'v1.0', 'config 1/3';
is $config<cache_path>, $tmp_cache_path, 'config 2/3';
is $config<refresh>, True, 'config 3/3';
