use v6;
use Grammar::Common::Expression::Prefix;
use Grammar::Common::Expression::Prefix::Actions;
use Test;

#############################################################################

grammar PostScript does Grammar::Common::Expression::Prefix {
	token c-variable {
		<[ a .. z ]> <[ a .. z A .. Z 0 .. 9 _ ]>*
	}
	token number {
		'-'?  [
			|| <[ 1 .. 7 ]> [ <[ 0 .. 7 ]> | '_' <[ 0 .. 7 ]> ]*
			|| 0
		]
	}
	token value {
		|| <c-variable>
		|| <number>
	}

	rule TOP { <expression> }
}

class Value { has ( $.value ) }
class Plus-Operation { has ( $.lhs, $.rhs ) }
class Minus-Operation { has ( $.lhs, $.rhs ) }
class Times-Operation { has ( $.lhs, $.rhs ) }
class Divide-Operation { has ( $.lhs, $.rhs ) }
class Modulo-Operation { has ( $.lhs, $.rhs ) }
class PostScript::Actions does Grammar::Common::Expression::Prefix::Actions {
	method value( $/ ) {
		make Value.new( :value( ~$/ ) );
	}
	method plus-operation( $lhs, $rhs ) {
		return Plus-Operation.new(
			:lhs( $lhs ),
			:rhs( $rhs )
		);
	}
	method minus-operation( $lhs, $rhs ) {
		return Minus-Operation.new(
			:lhs( $lhs ),
			:rhs( $rhs )
		);
	}
	method times-operation( $lhs, $rhs ) {
		return Times-Operation.new(
			:lhs( $lhs ),
			:rhs( $rhs )
		);
	}
	method divide-operation( $lhs, $rhs ) {
		return Divide-Operation.new(
			:lhs( $lhs ),
			:rhs( $rhs )
		);
	}
	method modulo-operation( $lhs, $rhs ) {
		return Modulo-Operation.new(
			:lhs( $lhs ),
			:rhs( $rhs )
		);
	}
	method TOP( $/ ) {
		make $/<expression>.ast;
	}
}

#############################################################################

my $p = PostScript.new;
my $a = PostScript::Actions.new;

#`(

subtest {
	is-deeply $p.parse( '+ 1 2', :actions( $a ) ).ast,
		Plus-Operation.new(
			:lhs( Value.new( :value( 1 ) ) ),
			:rhs( Value.new( :value( 2 ) ) ) );
	is-deeply $p.parse( '* 1 2', :actions( $a ) ).ast,
		Times-Operation.new(
			:lhs( Value.new( :value( 1 ) ) ),
			:rhs( Value.new( :value( 2 ) ) ) );
	is-deeply $p.parse( '- 1 2', :actions( $a ) ).ast,
		Minus-Operation.new(
			:lhs( Value.new( :value( 1 ) ) ),
			:rhs( Value.new( :value( 2 ) ) ) );
	is-deeply $p.parse( '/ 1 2', :actions( $a ) ).ast,
		Divide-Operation.new(
			:lhs( Value.new( :value( 1 ) ) ),
			:rhs( Value.new( :value( 2 ) ) ) );
}, 'single operation';

is-deeply $p.parse(
	'+ 1 * 2 3',
	:actions( $a )
).ast, Plus-Operation.new(
	:lhs( Value.new( :value( 1 ) ) ),
	:rhs( Times-Operation.new(
		:lhs( Value.new( :value( 2 ) ) ),
		:rhs( Value.new( :value( 3 ) ) ) ) ) );
is-deeply $p.parse(
	'- * 1 3 7',
	:actions( $a )
).ast, Minus-Operation.new(
	:lhs( Times-Operation.new(
		:lhs( Value.new( :value( 1 ) ) ),
		:rhs( Value.new( :value( 3 ) ) ) ) ),
	:rhs( Value.new( :value( 7 ) ) )
);
)

#`(
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
)

subtest {
	subtest {
		subtest {
			is-deeply $p.parse( '0', :actions( $a ) ).ast,
				Value.new( :value( 0 ) ), '0';
			is-deeply $p.parse( '1', :actions( $a ) ).ast,
				Value.new( :value( 1 ) ), '1';
			is-deeply $p.parse( '7', :actions( $a ) ).ast,
				Value.new( :value( 7 ) ), '7';
			is-deeply $p.parse( '-1', :actions( $a ) ).ast,
				Value.new( :value( -1 ) ), '-1';
		}, 'single digit';

		subtest {
			is-deeply $p.parse( '10', :actions( $a ) ).ast,
				Value.new( :value( 10 ) ), '10';
			is-deeply $p.parse( '1_2', :actions( $a ) ).ast,
				Value.new( :value( 12 ) ), '12';
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
