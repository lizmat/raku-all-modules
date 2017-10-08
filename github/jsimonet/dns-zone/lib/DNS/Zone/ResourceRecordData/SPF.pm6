use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::SPF is DNS::Zone::ResourceRecordData
{
    has Str $.spf is rw is required;

    method gist()
    { return $.spf; }

    method Str()
    { return $.spf; }

    method gen()
    { return $.spf; }

	method type()
	{ "SPF" }
}
