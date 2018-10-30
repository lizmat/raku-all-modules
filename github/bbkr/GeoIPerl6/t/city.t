use lib 'lib';

use Test;
use GeoIP::City;

plan( 7 );

my $g;

lives-ok { $g = GeoIP::City.new( directory => 't/databases' ) }, 'initialize';

# OpenDNS addresses are used for tests
my $ipv4 = '64.17.254.216';
my $ipv6 = '2001:200::';

is-deeply $g.locate( $ipv4 ), {
    'area_code' => 310,
    'city' => 'El Segundo',
    'continent_code' => 'NA',
    'country' => 'United States',
    'country_code' => 'US',
    'dma_code' => 803,
    'latitude' => 33.916401,
    'longitude' => -118.403999,
    'postal_code' => '90245',
    'region' => 'California',
    'region_code' => 'CA',
    'time_zone' => 'America/Los_Angeles'
}, 'locate by IPv4';

is-deeply $g.locate( $ipv6 ), {
    'area_code' => 0,
    'continent_code' => 'AS',
    'country' => 'Japan',
    'country_code' => 'JP',
    'dma_code' => 0,
    'latitude' => 36.0,
    'longitude' => 138.0
}, 'locate by IPv6';

is $g.locate( '0.0.0.0' ), Nil, 'not located';

lives-ok { $g = GeoIP::City.new( directory => '/' ) }, 'initialize custom directory';

throws-like { $g.locate( $ipv4 ) }, X::DatabaseMissing, 'missing IPv4 database';

throws-like { $g.locate( $ipv6 ) }, X::DatabaseMissing, 'missing IPv6 database';
