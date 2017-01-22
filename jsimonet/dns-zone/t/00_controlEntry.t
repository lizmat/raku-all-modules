use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'$ttl 1234',
	'$origin example.com',
	'$OrigIN example.com',
);

my @toTestAreNOk = (
	'$unexistant 1234',
	'$ttl',            # No value
	'$ttl str',        # No value
	'$origin',         # No value
	'ttl 1234',        # No $ prefix
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'controlEntry' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'controlEntry' ), $t;
}
