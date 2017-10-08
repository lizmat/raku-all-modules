use v6;
use Test;

use lib 'lib';
use DNS::Zone;
use DNS::Zone::ResourceRecord;
use DNS::Zone::ResourceRecordData::A;

# test zone type
# test some constructors arguments
my $zone = DNS::Zone.new;

is $zone.gen, '';

my $rdataA = DNS::Zone::ResourceRecordData::A.new( ipAdress => '10.0.0.1' );

# Constructor accepts empty parameters
my $rr = DNS::Zone::ResourceRecord.new(
	domainName => 'domainName',
	class      => 'in',
	ttl        => '3600',
	rdata      => $rdataA
);

$zone.add( :$rr );

is $zone.gen, 'domainName in 3600 A 10.0.0.1';

$zone.del( :1position );

is $zone.gen, '';

done-testing;
