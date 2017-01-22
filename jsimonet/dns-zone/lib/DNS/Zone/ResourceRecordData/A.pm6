use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::A is DNS::Zone::ResourceRecordData
{
	has Str $.ipAdress is rw is required;

	has $.changed = False;

	method ipAdress { self!proxy($!ipAdress) }

	method !proxy(\attr) {
		Proxy.new(
			FETCH => { attr },
			STORE => -> $, $value { $!changed = True; attr = $value }
		);
	}

	method gist()
	{ return $.ipAdress; }

	method Str()
	{ return $.ipAdress; }

	method gen()
	{ return $.ipAdress; }

	method type()
	{ "A" }
}
