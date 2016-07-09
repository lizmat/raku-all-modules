use Test;
use AWS::Pricing;

plan 3;

AWS::Pricing::config(cache_dir => 't');

# list-offers (json)
my $cached_offers_path = "t/offers.json";
my $cached_offers = slurp $cached_offers_path;
my $offers = AWS::Pricing::list-services;
is $offers, $cached_offers, 'list-offers 1/1';

# service-offers (json)
my $service_code = 'AmazonS3';
my $cached_service_offers_path = "t/service-offers-$service_code.json";
my $cached_service_offers = slurp $cached_service_offers_path;
my $service_offers = AWS::Pricing::service-offers(service_code => $service_code);
is $service_offers, $cached_service_offers, 'service-offers 1/2';

# service-offers (csv)
$service_code = 'AmazonVPC';
$cached_service_offers_path = "t/service-offers-$service_code.csv";
$cached_service_offers = slurp $cached_service_offers_path;
$service_offers = AWS::Pricing::service-offers(service_code => $service_code, format => 'csv');
is $service_offers, $cached_service_offers, 'service-offers 2/2';
