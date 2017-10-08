use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::AAAA;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::AAAA.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::AAAA.new(
	ip6Adress => '::1'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::AAAA;

is $rdata.gen, '::1', 'Test generate ResourceRecordDataAAAA string';

done-testing;
