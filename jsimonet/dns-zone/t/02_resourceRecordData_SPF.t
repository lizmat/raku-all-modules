use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::SPF;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::SPF.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::SPF.new(
	spf => 'data'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::SPF;

is $rdata.gen, 'data', 'Test generate ResourceRecordDataSPF string';

done-testing;
