use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'testcomment 3600 A 10.0.0.1 ; this is a comment', # A resource record with a comment
	'; only a comment',
	' ; comment preceded by space',
	"(\n) 	; comment preceded by some rrSpace",
	'( dname 1234 a 10.0.0.3 )',
	'()',
	' ',
	"; comment ending without newline",
);

my @toTestAreNOk = (
	'(',                                 # Parentheses count fails
	"  ; comment ending with newline\n",
	'notype',
	'notype in',
	'notype in 1234',
	'notype 1234 in',
	'nottl in txt "no ttl in rr"',
	'( dname a 10.0.0.3 )',              # No TTL defined
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'entry' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'entry' ), $t;
}
