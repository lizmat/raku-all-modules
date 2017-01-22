use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::SOA;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainName => 'domainName',
		domainAction => 'domainAction',
		serial => 2016103101,
		refresh => 3600,
		expire => 123,
		min => 321
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainAction => 'domainAction',
		serial => 2016103101,
		refresh => 3600,
		expire => 123,
		min => 321
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainName => 'domainName',
		serial => 2016103101,
		refresh => 3600,
		expire => 123,
		min => 321
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainName => 'domainName',
		domainAction => 'domainAction',
		refresh => 3600,
		expire => 123,
		min => 321
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainName => 'domainName',
		domainAction => 'domainAction',
		serial => 2016103101,
		expire => 123,
		min => 321
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainName => 'domainName',
		domainAction => 'domainAction',
		serial => 2016103101,
		refresh => 3600,
		min => 321
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);


throws-like(
	&{ DNS::Zone::ResourceRecordData::SOA.new(
		domainName => 'domainName',
		domainAction => 'domainAction',
		serial => 2016103101,
		refresh => 3600,
		expire => 123,
	)},
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::SOA.new(
	domainName   => 'domainName',
	domainAction => 'domainAction',
	serial       => 2016103101,
	refresh      => 3600,
	retry        => 456,
	expire       => 123,
	min          => 321
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::SOA;

is $rdata.gen, 'domainName domainAction 2016103101 3600 456 123 321', 'Test generate ResourceRecordDataSOA string';

done-testing;
