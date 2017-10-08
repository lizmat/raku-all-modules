use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::DNAME is DNS::Zone::ResourceRecordData
{
	has Str $.domainName is rw is required;

	method gist()
	{ return "(Domain=$.domainName)"; }

	method Str()
	{ return $.domainName; }

	method gen()
	{ return $.domainName; }

	method type()
	{ "DNAME" }
}
