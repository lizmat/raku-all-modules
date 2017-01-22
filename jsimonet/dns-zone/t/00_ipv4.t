use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# IPv4
my @toTestAreOk = (
	'10.0.0.0',
	'30.0.0.100',
);

my @toTestAreNOk = (
	'10.0',
	'10.0.0.257',
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'ipv4' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'ipv4' ), $t;
}
