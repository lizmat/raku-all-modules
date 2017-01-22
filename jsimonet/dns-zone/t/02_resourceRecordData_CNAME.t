use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::CNAME;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::CNAME.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::CNAME.new(
	domainName => 'name'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::CNAME;

is $rdata.gen, 'name', 'Test generate ResourceRecordDataCNAME string';

done-testing;
