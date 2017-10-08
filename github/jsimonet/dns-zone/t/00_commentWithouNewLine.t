use v6;

use Test;


use lib 'lib';
use DNS::Zone::Grammars::Modern;

# Comments
my @toTestAreOk = (
	';coucou';
	';blouh;()-@';
);
my @toTestAreNOk = (
	'nope',
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'commentWithoutNewline' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'commentWithoutNewline' ), $t;
}

done-testing;
