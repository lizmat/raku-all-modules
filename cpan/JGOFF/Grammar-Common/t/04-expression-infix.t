use v6;
use Grammar::Common::Expression::Infix;
use Test;

#############################################################################

grammar InScript does Grammar::Common::Expression::Infix {
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

my $i = InScript.new;

subtest {
	nok $i.parse( '' ), 'empty expression';

	subtest {
		subtest {
			nok $i.parse( 'Σ' ), 'unparsable character';
			nok $i.parse( '३' ), 'unparsable number';
			nok $i.parse( '9' ), 'out-of-band digit';
			nok $i.parse( '[' ), 'out-of-band character';
			nok $i.parse( '_' ), 'internal character';
		}, 'unparsable text';

		subtest {
			nok $i.parse( '+' ), 'plus';
			nok $i.parse( '-' ), 'minus';
			nok $i.parse( '*' ), 'times';
			nok $i.parse( '/' ), 'divide';
		}, 'operators standalone';
	}, 'single character';

	subtest {
		nok $i.parse( '+-' ), 'operators';
		nok $i.parse( '-+' ), 'operators';
		nok $i.parse( '00' ), 'invalid number';
		nok $i.parse( '_0' ), 'invalid number';
		nok $i.parse( '_9' ), 'another invalid number';
	}, 'multiple characters';

	subtest {
		subtest {
			nok $i.parse( '+0' );
			nok $i.parse( '*0' );
			nok $i.parse( '/0' );
		}, 'without whitespace';

		subtest {
			nok $i.parse( '+ 0' );
			nok $i.parse( '* 0' );
			nok $i.parse( '/ 0' );
		}, 'with whitespace';
	}, 'operator with single operand';

	subtest {
		subtest {
			nok $i.parse( '+-1' );
			nok $i.parse( '--1' );
			nok $i.parse( '*-1' );
			nok $i.parse( '/-1' );
		}, 'without whitespace';

		subtest {
			nok $i.parse( '+ -1' );
			nok $i.parse( '- -1' );
			nok $i.parse( '* -1' );
			nok $i.parse( '/ -1' );
		}, 'with whitespace';
	}, 'operator with negative single operand';

	subtest {
		nok $i.parse( '1 1' );
		nok $i.parse( '-1 1' );
	}, 'two operands';

	subtest {
		nok $i.parse( '(1' );
		nok $i.parse( '1)' );
		nok $i.parse( ')1' );
		nok $i.parse( '1(' );
	}, 'unbalanced parens';
}, 'failing tests';

subtest {
	ok $i.parse('1'), '1';

	subtest {
		ok $i.parse('1+1'), '1+1';
		ok $i.parse('1-1'), '1-1';
		ok $i.parse('1*1'), '1*1';
		ok $i.parse('1/1'), '1/1';
		ok $i.parse('1%1'), '1%1';

		subtest {
			subtest {
				ok $i.parse('-1+1'), '-1+1';
				ok $i.parse('-1-1'), '-1-1';
				ok $i.parse('-1*1'), '-1*1';
				ok $i.parse('-1/1'), '-1/1';
				ok $i.parse('-1%1'), '-1%1';
			}, 'first';

			subtest {
				ok $i.parse('1+-1'), '1+-1';
				ok $i.parse('1--1'), '1--1';
				ok $i.parse('1*-1'), '1*-1';
				ok $i.parse('1/-1'), '1/-1';
				ok $i.parse('1%-1'), '1%-1';
			}, 'second';

			subtest {
				ok $i.parse('-1+-1'), '-1+-1';
				ok $i.parse('-1--1'), '-1--1';
				ok $i.parse('-1*-1'), '-1*-1';
				ok $i.parse('-1/-1'), '-1/-1';
				ok $i.parse('-1%-1'), '-1%-1';
			}, 'both';
		}, 'negative numbers';

		subtest {
			ok $i.parse('1+1+1'), '1+1+1';
			ok $i.parse('1+1-1'), '1+1-1';
			ok $i.parse('1+1*1'), '1+1*1';
			ok $i.parse('1+1/1'), '1+1/1';
			ok $i.parse('1+1%1'), '1+1%1';

			ok $i.parse('1-1+1'), '1-1+1';
			ok $i.parse('1-1-1'), '1-1-1';
			ok $i.parse('1-1*1'), '1-1*1';
			ok $i.parse('1-1/1'), '1-1/1';
			ok $i.parse('1-1%1'), '1-1%1';

			ok $i.parse('1*1+1'), '1*1+1';
			ok $i.parse('1*1-1'), '1*1-1';
			ok $i.parse('1*1*1'), '1*1*1';
			ok $i.parse('1*1/1'), '1*1/1';
			ok $i.parse('1*1%1'), '1*1%1';

			ok $i.parse('1/1+1'), '1/1+1';
			ok $i.parse('1/1-1'), '1/1-1';
			ok $i.parse('1/1*1'), '1/1*1';
			ok $i.parse('1/1/1'), '1/1/1';
			ok $i.parse('1/1%1'), '1/1%1';

			ok $i.parse('1%1+1'), '1%1+1';
			ok $i.parse('1%1-1'), '1%1-1';
			ok $i.parse('1%1*1'), '1%1*1';
			ok $i.parse('1%1/1'), '1%1/1';
			ok $i.parse('1%1%1'), '1%1%1';
		}, 'another operator';
	}, 'with operator';
}, 'no parens';

subtest {
	ok $i.parse('(1)'), '(1)';

	subtest {
		ok $i.parse('(1)+1'), '(1)+1';
		ok $i.parse('1+(1)'), '1+(1)';
		ok $i.parse('(1)+(1)'), '(1)+(1)';

		subtest {
			ok $i.parse('(1)+1+1'), '(1)+1+1';
			ok $i.parse('1+(1)+1'), '1+(1)+1';
			ok $i.parse('(1)+(1)+1'), '(1)+(1)+1';
			ok $i.parse('1+1+(1)'), '1+1+(1)';
			ok $i.parse('(1)+1+(1)'), '(1)+1+(1)';
			ok $i.parse('1+(1)+(1)'), '1+(1)+(1)';
			ok $i.parse('(1)+(1)+(1)'), '(1)+(1)+(1)';
		}, 'another operator';
	}, 'with operator';
}, 'paren around single term';

subtest {
	ok $i.parse('-(1)'), '-(1)';
	ok $i.parse('-(1+1)'), '-(1+1)';
	ok $i.parse('1-(1)'), '1-(1)'; # equivalent to '1-1', not '1 (-1)'
	ok $i.parse('1--(1)'), '1--(1)';
}, 'negated parens';

subtest {
	ok $i.parse('(1+1)'), '(1+1)';

	subtest {
		ok $i.parse('(1+1)+1'), '(1+1)+1';
		ok $i.parse('1+(1+1)'), '1+(1+1)';

		subtest {
			ok $i.parse('(1+1)+1+1'), '(1+1)+1+1';
			ok $i.parse('1+1+(1+1)'), '1+1+(1+1)';
			ok $i.parse('(1+1)+(1+1)'), '(1+1)+(1+1)';
		}, 'even more operators';

		ok $i.parse('1+(1+1)+1'), '1+(1+1)+1';
	}, 'with another operator';

	subtest {
		ok $i.parse('((1+1))'), '((1+1))';

		subtest {
			ok $i.parse('((1+1)+1)'), '((1+1)+1)';
			ok $i.parse('(1+(1+1))'), '(1+(1+1))';

			subtest {
				ok $i.parse('((1+1)+1+1)'), '((1+1)+1+1)';
				ok $i.parse('(1+1+(1+1))'), '(1+1+(1+1))';
				ok $i.parse('((1+1)+(1+1))'), '((1+1)+(1+1))';
			}, 'even more operators';

			ok $i.parse('(1+(1+1)+1)'), '(1+(1+1)+1)';
		}, 'with another operator';
	}, 'paren around statement';
}, 'paren around operator';

done-testing;

# vim: ft=perl6
