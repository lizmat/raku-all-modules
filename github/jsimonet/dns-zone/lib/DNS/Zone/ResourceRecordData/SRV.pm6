use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::SRV is DNS::Zone::ResourceRecordData
{
	has Int $.priority is rw is required;
	has Int $.weight   is rw is required;
	has Int $.port     is rw is required;
	has Str $.target   is rw is required;

	method gist()
	{ return "$.priority $.weight $.port $.target"; }

	method Str()
	{ return "$.priority $.weight $.port $.target"; }

	method gen()
	{ return "$.priority $.weight $.port $.target"; }

	method type()
	{ "SRV" }
}
