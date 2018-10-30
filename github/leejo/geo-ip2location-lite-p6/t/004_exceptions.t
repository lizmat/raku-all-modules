#!perl6

use Test;
use Geo::IP2Location::Lite;

plan 5;

my $good_file = 'samples/IP-COUNTRY-SAMPLE.BIN';
my $obj = Geo::IP2Location::Lite.new(
	file => $good_file
);;

is( $obj.get_country_short( '1.0.3.4' ),'-',"lookup with missing IP" );
is( $obj.get_country_short( '255.255.255.254' ),'UNKNOWN IP ADDRESS',"with not covered IP" );

throws-like({ $obj.get_country_short( 'weird1.1.1.1stuff' ) },Exception );
throws-like({ $obj.get_country_short( '۳.۳.۳.۳' ) },Exception );

is(
	$obj.get_latitude( '1.0.3.4' ),
	'This parameter is unavailable in selected .BIN data file. Please upgrade data file.',
	'data unsupported function'
);

done-testing;
