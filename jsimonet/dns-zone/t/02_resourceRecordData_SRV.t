use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::SRV;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::SRV.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SRV.new(
		weight   => 20,
		port     => 1234,
		target   => 'target',
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SRV.new(
		priority => 10,
		port     => 1234,
		target   => 'target',
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SRV.new(
		priority => 10,
		weight   => 20,
		target   => 'target',
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SRV.new(
		priority => 10,
		weight   => 20,
		port     => 1234,
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::SRV.new(
	priority => 10,
	weight   => 20,
	port     => 1234,
	target   => 'target',
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::SRV;

is $rdata.gen, '10 20 1234 target', 'Test generate ResourceRecordDataSRV string';

done-testing;
