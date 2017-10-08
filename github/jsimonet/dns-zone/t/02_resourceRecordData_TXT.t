use v6;

use Test;

use lib 'lib';

use DNS::Zone::ResourceRecordData::TXT;

# Test that attribues are required
# (Throws an exception if an attribute is required, but not provided)
throws-like(
	&{ DNS::Zone::ResourceRecordData::TXT.new },
	X::Attribute::Required,
	'Cannot construct a resource record without parameters'
);

my $rdata = DNS::Zone::ResourceRecordData::TXT.new(
	txt => 'txt'
);

isa-ok $rdata, DNS::Zone::ResourceRecordData::TXT;

is $rdata.gen, 'txt', 'Test generate ResourceRecordDataTXT string';

done-testing;
