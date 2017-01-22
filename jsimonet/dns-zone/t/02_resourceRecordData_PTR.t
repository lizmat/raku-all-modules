use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::PTR;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::PTR.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::PTR.new(
	domainName => 'data'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::PTR;

is $rdata.gen, 'data', 'Test generate ResourceRecordDataPTR string';

done-testing;
