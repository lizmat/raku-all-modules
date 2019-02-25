use v6;
use Grammar::Common::Expression::Prefix;
use Test;

#############################################################################

grammar PostScript does Grammar::Common::Expression::Prefix {
	token c-variable {
		<[ a .. z ]> <[ a .. z A .. Z 0 .. 9 _ ]>*
	}
	token number {
		'-'?  [
			|| <[ 1 .. 7 ]> [ <[ 0 .. 7 _ ]> | '_' <[ 0 .. 7 ]> ]*
			|| 0
		]
	}
	token value {
		|| <c-variable>
		|| <number>
	}

	rule TOP { <expression> }
}

#############################################################################

my $p = PostScript.new;

subtest {
	nok $p.parse( '' ), 'empty expression';

	subtest {
		subtest {
			nok $p.parse( 'Σ' ), 'unparsable character';
			nok $p.parse( '३' ), 'unparsable number';
			nok $p.parse( '9' ), 'out-of-band digit';
			nok $p.parse( '[' ), 'out-of-band character';
			nok $p.parse( '_' ), 'internal character';
		}, 'unparsable text';

		subtest {
			nok $p.parse( '+' ), 'plus';
			nok $p.parse( '-' ), 'minus';
			nok $p.parse( '*' ), 'times';
			nok $p.parse( '/' ), 'divide';
		}, 'operators standalone';
	}, 'single character';

	subtest {
		nok $p.parse( '+-' ), 'operators';
		nok $p.parse( '-+' ), 'operators';
		nok $p.parse( '00' ), 'invalid number';
		nok $p.parse( '_0' ), 'invalid number';
		nok $p.parse( '_9' ), 'another invalid number';
	}, 'multiple characters';

	subtest {
		subtest {
			nok $p.parse( '+0' );
			nok $p.parse( '*0' );
			nok $p.parse( '/0' );
		}, 'without whitespace';

		subtest {
			nok $p.parse( '+ 0' );
			nok $p.parse( '* 0' );
			nok $p.parse( '/ 0' );
		}, 'with whitespace';
	}, 'operator with single operand';

	subtest {
		subtest {
			nok $p.parse( '+-1' );
			nok $p.parse( '--1' );
			nok $p.parse( '*-1' );
			nok $p.parse( '/-1' );
		}, 'without whitespace';

		subtest {
			nok $p.parse( '+ -1' );
			nok $p.parse( '- -1' );
			nok $p.parse( '* -1' );
			nok $p.parse( '/ -1' );
		}, 'with whitespace';
	}, 'operator with negative single operand';

	subtest {
		nok $p.parse( '1 1' );
		nok $p.parse( '-1 1' );
		nok $p.parse( '1 -1' );
		nok $p.parse( '-1 -1' );
	}, 'two operands';
}, 'failing tests';

subtest {
	subtest {
		subtest {
			ok $p.parse( '0' ), '0';
			ok $p.parse( '1' ), '1';
			ok $p.parse( '7' ), '7';
			ok $p.parse( '-1' ), '-1';
		}, 'single digit';

		subtest {
			ok $p.parse( '10' ), '10';
			ok $p.parse( '1_0' ), '1_0';
		}, 'multiple digits';
	}, 'number';

	subtest {
		ok $p.parse( 'a' ), 'a';
		ok $p.parse( 'a_' ), 'a_';
	}, 'c-variable';
}, 'value';

subtest {
	subtest {
		ok $p.parse( '+ 0 1' );
		ok $p.parse( '- 0 1' );
		ok $p.parse( '* 0 1' );
		ok $p.parse( '/ 0 1' );
	}, 'op number number';

	subtest {
		ok $p.parse( '+ 0 b' );
		ok $p.parse( '- 0 b' );
		ok $p.parse( '* 0 b' );
		ok $p.parse( '/ 0 b' );
	}, 'op number variable';

	subtest {
		ok $p.parse( '+ a 1' );
		ok $p.parse( '- a 1' );
		ok $p.parse( '* a 1' );
		ok $p.parse( '/ a 1' );
	}, 'op variable number';

	subtest {
		ok $p.parse( '+ a b' );
		ok $p.parse( '- a b' );
		ok $p.parse( '* a b' );
		ok $p.parse( '/ a b' );
	}, 'op variable variable';
}, 'single operand';

subtest {
	ok $p.parse( '+ + 1 2 3' );
	ok $p.parse( '+ 1 + 2 3' );

	ok $p.parse( '+ + -1 -2 -3' );
	ok $p.parse( '+ - -1 -2 -3' );
	ok $p.parse( '+ -1 - -2 -3' );
#	ok $p.parse( '++a 2c' );
}, 'two operands';

done-testing;

# vim: ft=perl6
