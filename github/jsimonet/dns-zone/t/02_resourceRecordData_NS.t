use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::NS;

plan 3;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::NS.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::NS.new(
	domainName => 'name'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::NS;

is $rdata.gen, 'name', 'Test generate ResourceRecordDataNS string';
