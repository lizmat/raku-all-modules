use Test;

use AWS::Pricing;

plan 6;

my $region = 'us-east-1';
my $api_version = 'v1.0';
my $service_code = 'AmazonS3';

# use
use-ok('AWS::Pricing');

# new
my $r1 = AWS::Pricing.new(aws_region => $region, api_version => $api_version);

is $r1.aws_region, 'us-east-1', 'new 1/3';
is $r1.api_version, 'v1.0', 'new 2/3';
isa-ok $r1, AWS::Pricing, 'new 3/3';

# list-offers
ok $r1.list-offers, 'list-offers 1/1';

# get-service-offers
ok $r1.get-service-offers($service_code), 'get-service-offers 1/1';
