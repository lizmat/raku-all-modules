use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::MX;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::MX.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::MX.new( mxPref => 10 ) },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::MX.new( domainName => 'name' ) },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::MX.new(
	mxPref => 10, domainName => 'mxname'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::MX;

is $rdata.gen, '10 mxname', 'Test generate ResourceRecordDataA string';

done-testing;
