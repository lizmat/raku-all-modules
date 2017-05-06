use v6;
use Test;
use lib 'lib';
use AWS::Pricing;

plan 5;

# list-offers (json)
my $r1_cached_offers = slurp "t/data/offers.json";
my $r1_offers        = AWS::Pricing::services(
    config => AWS::Pricing::config(cache_path => 't/data')
);
is $r1_offers, $r1_cached_offers, 'list-offers 1/1: json';

# service-offers (json)
my $r2_service_code          = 'AmazonS3';
my $r2_cached_service_offers = slurp "t/data/service-offers-$r2_service_code.json";
my $r2_service_offers        = AWS::Pricing::service-offers(
    config       => AWS::Pricing::config(cache_path => 't/data'),
    service_code => $r2_service_code
);
is $r2_service_offers, $r2_cached_service_offers, 'service-offers 1/4: json';

# service-offers (json: region)
my $r3_service_code          = 'AmazonS3';
my $r3_region                = 'eu-west-1';
my $r3_cached_service_offers = slurp "t/data/service-offers-{$r3_service_code}-{$r3_region}.json";
my $r3_service_offers        = AWS::Pricing::service-offers(
    config       => AWS::Pricing::config(cache_path => 't/data'),
    service_code => $r3_service_code,
    region       => $r3_region
);
is $r3_service_offers, $r3_cached_service_offers, 'service-offers 2/4: json (region)';

# service-offers (csv)
my $r4_service_code = 'AmazonVPC';
my $r4_cached_service_offers = slurp "t/data/service-offers-$r4_service_code.csv";
my $r4_service_offers = AWS::Pricing::service-offers(
    config       => AWS::Pricing::config(cache_path => 't/data'),
    service_code => $r4_service_code,
    format       => 'csv'
);
is $r4_service_offers, AWS::Pricing::strip-header-csv($r4_cached_service_offers), 'service-offers 3/4: csv';

# service-offers (csv: region)
my $r5_service_code          = 'AmazonS3';
my $r5_region                = 'eu-west-1';
my $r5_cached_service_offers = slurp "t/data/service-offers-{$r5_service_code}-{$r5_region}.csv";
my $r5_service_offers        = AWS::Pricing::service-offers(
    config       => AWS::Pricing::config(cache_path => 't/data'),
    service_code => $r5_service_code,
    format       => 'csv',
    region       => $r5_region
);
is $r5_service_offers, AWS::Pricing::strip-header-csv($r5_cached_service_offers), 'service-offers 4/4: csv (region)';
