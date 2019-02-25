use v6;

=begin pod

=head1 Grammar::Common

L<Grammar::Common> gives you a library of common grammar roles to use in
your own code, from simple numbers and strings to vaidation tools.

=head1 Synopsis

    use Grammar::Common::Expression::Infix;

    grammar PostScript does Grammar::Common::Expression::Infix {

        token value { <[ - + ]>? <[ 0 .. 9 ]>+ }

        rule TOP { <expression> }
    }

    my $x = InScript.parse( '1 + 3' );

=head1 Documentation

=head2 grammar roles

  =item L<Expression::Infix>

  Match '2 + -6 / 3' and similar expressions.

  Use C<< <expression> >> to match prefix expressions.

=end pod

role Grammar::Common::Expression::Infix
	{
	token open-paren-symbol { '(' }
	token close-paren-symbol { ')' }

	token plus-symbol { '+' }
	token minus-symbol { '-' }
	token times-symbol { '*' }
	token divide-symbol { '/' }
	token modulo-symbol { '%' }

	rule term
		{
		|| <minus-symbol>?
			<open-paren-symbol> <expression> <close-paren-symbol>
		|| <value>
		}

	proto rule operation { * }
	rule operation:sym<plus>
		{
		|| <lhs=term> <plus-symbol> <rhs=expression>
		}

	rule operation:sym<times>
		{
		|| <lhs=term> <times-symbol> <rhs=expression>
		}

	rule operation:sym<minus>
		{
		|| <lhs=term> <minus-symbol> <rhs=expression>
		}

	rule operation:sym<divide>
		{
		|| <lhs=term> <divide-symbol> <rhs=expression>
		}

	rule operation:sym<modulo>
		{
		|| <lhs=term> <modulo-symbol> <rhs=expression>
		}

	rule expression
		{
		|| <operation>
		|| <term>
		}
	}

# vim: ft=perl6
