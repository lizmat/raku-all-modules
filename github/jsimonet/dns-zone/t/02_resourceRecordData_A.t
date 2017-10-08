use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::A;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::A.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::A.new(
	ipAdress => '10.0.0.1'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::A;

is $rdata.gen, '10.0.0.1', 'Test generate ResourceRecordDataA string';

done-testing;
