use v6;
use Test;

use lib 'lib';

use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'2147483647',
	'2147483647s',
	'35791394m',
	'596523h',
	'24855d',
	'3550w',
);

my @toTestAreNOk = (
	'',
	'0', # Must be positive
	'2147483648',
	'2147483648s',
	'35791395m',
	'596524h',
	'24856d',
	'3551w',
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'ttl' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'ttl' ), $t;
}

done-testing;
