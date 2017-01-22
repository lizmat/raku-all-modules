use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

plan 2;

subtest {
	# Comments with an optional carriage return
	my @toTestAreOk = (
		";\n",
		";comment\n",
		";comment",
	);
	my @toTestAreNOk = (
		' ;fail\n',
		";comm\n\n", # Only one newline
	);

	plan @toTestAreOk.elems + @toTestAreNOk.elems;

	for @toTestAreOk -> $t
	{
		ok DNS::Zone::Grammars::Modern.parse($t, rule => 'comment' ), $t;
	}

	for @toTestAreNOk -> $t
	{
		nok DNS::Zone::Grammars::Modern.parse($t, rule => 'comment' ), $t;
	}

},  'Comments';

subtest {
	# Comments without a new line

	my @toTestAreOk = (
		';comment',
	);

	my @toTestAreNOk = (
		";comment\n",
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

}, 'Comments without a new line';
