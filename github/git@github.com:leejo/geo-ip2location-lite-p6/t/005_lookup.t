#!perl6

use Test;
use Geo::IP2Location::Lite;

plan 10;

my $file = 'samples/IP-COUNTRY-SAMPLE.BIN';

my $ip2 = Geo::IP2Location::Lite.new(
	file => $file
);

my %ips = (
	'19.5.10.1' => 'US',
	'25.5.10.2' => 'GB',
	'43.5.10.3' => 'JP',
	'47.5.10.4' => 'CA',
	'51.5.10.5' => 'GB',
	'53.5.10.6' => 'DE',
	'80.5.10.7' => 'GB',
	'81.5.10.8' => 'IL',
	'83.5.10.9' => 'PL',
	'85.5.10.0' => 'CH',
);

for %ips.keys -> $k {
	is( $ip2.get_country_short( $k ),%ips{$k},"$k resolves to { %ips{$k} }" );
}

done-testing;
