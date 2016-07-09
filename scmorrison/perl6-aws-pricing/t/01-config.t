use Test;
use AWS::Pricing;

plan 3;

# config
my $tmp_cache_dir = $*TMPDIR ~ "/aws-pricing-config-test";
AWS::Pricing::config(cache_dir => $tmp_cache_dir);

my $cache_path = AWS::Pricing::<$cache_path>;
is $cache_path, $tmp_cache_dir, 'config 1/3';

my $aws_region = AWS::Pricing::<$aws_region>;
is $aws_region, 'us-east-1', 'config 2/3';

my $api_version = AWS::Pricing::<$api_version>;
is $api_version, 'v1.0', 'config 3/3';
