#!perl6

use Geo::IP2Location::Lite;

sub MAIN( Str :$ip ) {
	my $obj = Geo::IP2Location::Lite.new(
		file => $*PROGRAM.dirname ~ '/samples/IP-COUNTRY-REGION-CITY.BIN.201607',
	);

	say $obj.get_country_short( $ip );
}
