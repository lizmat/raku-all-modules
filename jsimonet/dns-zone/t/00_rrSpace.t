use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	' ',
	'  ',
	'	',
	" 	",
	'(',
	'()',
	"(\n)",
);

my @toTestAreNOk = (
	"\n",
	')', # Not valid because parenCount is equal to 0
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'rrSpace' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'rrSpace' ), $t;
}
