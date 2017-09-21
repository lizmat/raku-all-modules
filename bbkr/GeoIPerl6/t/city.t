use lib 'lib';

use Test;
use GeoIP::City;

plan( 7 );

my $g;

lives-ok { $g = GeoIP::City.new }, 'initialize';

# OpenDNS addresses are used for tests
my $ipv4 = '208.67.222.222';
my $ipv6 = '2620:0:ccc::2';

is-deeply $g.locate( $ipv4 ), {
    'area_code' => 415,
    'city' => 'San Francisco',
    'continent_code' => 'NA',
    'country' => 'United States',
    'country_code' => 'US',
    'dma_code' => 807,
    'latitude' => 37.774899,
    'longitude' => -122.419403,
    'postal_code' => '94119',
    'region' => 'California',
    'region_code' => 'CA',
    'time_zone' => 'America/Los_Angeles'
}, 'locate by IPv4';

is-deeply $g.locate( $ipv6 ), {
    'area_code' => 0,
    'continent_code' => 'NA',
    'country' => 'United States',
    'country_code' => 'US',
    'dma_code' => 0,
    'latitude' => 37.750999,
    'longitude' => -97.821999
}, 'locate by IPv6';

is $g.locate( '0.0.0.0' ), Nil, 'not located';

lives-ok { $g = GeoIP::City.new( directory => '/' ) }, 'initialize custom directory';

throws-like { $g.locate( $ipv4 ) }, X::DatabaseMissing, 'missing IPv4 database';

throws-like { $g.locate( $ipv6 ) }, X::DatabaseMissing, 'missing IPv6 database';
