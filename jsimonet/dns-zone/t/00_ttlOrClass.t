use v6;
use Test;

use lib 'lib';

use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'',
	'in ',
	'123 ',
	'in 123 ',
	'123 in ',
);

my @toTestAreNOk = (
	'in in',
	'123 123',
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'ttlOrClass' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'ttlOrClass' ), $t;
}

done-testing;
