use v6;
use Test;

use lib 'lib';

use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'2000:1000:1000:1000:2000:1000:1000:1000',
	'aaaa:1234:4567:7898:aaaa:1234:4567:7898',
	'2000::2000:1000:1000:1000',
	'2000::2000:1000:1000',
	'aaaa:1234:4567:7898:aaaa::4567:7898',
	'::', # 0000:0000:0000:0000:0000:0000:0000:0000
	'::1',
	'::10.10.1.1',
	'2000:123:abcd:123:456:789:10.10.1.1',
	'2000::123:abcd:10.10.1.1',
);

my @toTestAreNOk = (
	'2000:1000:1000:1000:2000:1000:1000::1000', # Too much elements
	'1000:10.0.0.1',                            # Not enough elements
	'1000:2000',                                # Not enough elements
	'1000::2000::3000',                         # Too much ::
	'10.0.0.1:1000::2000',                      # IPv4 must follow IPv6 part
	':1000::2000:10.0.0.1',                     # Cannot begins with :
	'1000::2000:10.0.0',                       # Incomplete IPv4
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'ipv6' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'ipv6' ), $t;
}

done-testing;
