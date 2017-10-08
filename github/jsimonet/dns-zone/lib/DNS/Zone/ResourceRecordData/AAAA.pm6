use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::AAAA is DNS::Zone::ResourceRecordData
{
	has Str $.ip6Adress is rw is required;

	method gist()
	{ return $.ip6Adress; }

	method Str()
	{ return $.ip6Adress; }

	method gen()
	{ return $.ip6Adress; }

	method type
	{ "AAAA" }
}
