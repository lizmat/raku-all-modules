use lib 'lib';

use Test;
use GeoIP::City;

plan( 7 );

my $g;

lives-ok { $g = GeoIP::City.new }, 'initialize';

is-deeply $g.locate( '8.8.8.8' ), {
    'area_code' => 650,
    'city' => 'Mountain View',
    'continent_code' => 'NA',
    'country' => 'United States',
    'country_code' => 'US',
    'dma_code' => 807,
    'latitude' => 37.384499,
    'longitude' => -122.088097,
    'postal_code' => '94040',
    'region' => 'California',
    'region_code' => 'CA',
    'time_zone' => 'America/Los_Angeles'
}, 'locate by IPv4';

is-deeply $g.locate( '2001:4860:4860::8888' ), {
    'area_code' => 0,
    'continent_code' => 'NA',
    'country' => 'United States',
    'country_code' => 'US',
    'dma_code' => 0,
    'latitude' => 38.0,
    'longitude' => -97.0
}, 'locate by IPv6';

is $g.locate( '0.0.0.0' ), Nil, 'not located';

lives-ok { $g = GeoIP::City.new( directory => '/' ) }, 'initialize custom directory';

throws-like { $g.locate( '8.8.8.8' ) }, X::DatabaseMissing, 'missing IPv4 database';

throws-like { $g.locate( '2001:4860:4860::8888' ) }, X::DatabaseMissing, 'missing IPv6 database';
