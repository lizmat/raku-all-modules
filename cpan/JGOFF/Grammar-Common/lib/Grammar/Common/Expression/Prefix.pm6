use v6;

=begin pod

=head1 Grammar::Common

L<Grammar::Common> gives you a library of common grammar roles to use in
your own code, from simple numbers and strings to vaidation tools.

=head1 Synopsis

    use Grammar::Common::Expression::Prefix;

    grammar PostScript does Grammar::Common::Expression::Prefix {

        token value { <[ - + ]>? <[ 0 .. 9 ]>+ }

        rule TOP { <expression> }
    }

    my $x = PostScript.parse( '+ 1 3' );

=head1 Documentation

=head2 grammar roles

  =item L<Expression::Prefix>

  Match '+ 2 / -6 3' and similar expressions.

  Use C<< <expression> >> to match prefix expressions.

=end pod

role Grammar::Common::Expression::Prefix
	{
	token plus-symbol { '+' }
	token minus-symbol { '-' }
	token times-symbol { '*' }
	token divide-symbol { '/' }
	token modulo-symbol { '%' }

	proto rule operation { * }
	rule operation:sym<plus>
		{
		<plus-symbol> <lhs=expression> <rhs=expression>
		}

	rule operation:sym<minus>
		{
		<minus-symbol> <lhs=expression> <rhs=expression>
		}

	rule operation:sym<times>
		{
		<times-symbol> <lhs=expression> <rhs=expression>
		}

	rule operation:sym<divide>
		{
		<divide-symbol> <lhs=expression> <rhs=expression>
		}

	rule operation:sym<modulo>
		{
		<modulo-symbol> <lhs=expression> <rhs=expression>
		}

	rule expression
		{
		|| <value>
		|| <operation>
		}
	}

# vim: ft=perl6
