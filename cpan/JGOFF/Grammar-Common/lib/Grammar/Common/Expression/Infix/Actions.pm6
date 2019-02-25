use v6;

=begin pod

=head1 Grammar::Common::Actions

L<Grammar::Common::Actions> gives you a library of common grammar action roles
to use in your own code, from simple numbers and strings to vaidation tools.

=head1 Synopsis

    use Grammar::Common::Expression::Infix;
    use Grammar::Common::Expression::Infix::Actions;

    grammar PostScript does Grammar::Common::Expression::Infix {

        token value { <[ - + ]>? <[ 0 .. 9 ]>+ }

        rule TOP { <expression> }
    }

    class PostScript::Actions {
        also does Grammar::Common::Expression::Infix::Actions;
    }

    my $x = PostScript.parse( '+ 1 3', :actions( PostScript::Actions.new ).ast;
    say $x.perl;

=head1 Documentation

=head2 grammar roles

  =item L<Expression::Infix::Actions>

  Create an expression tree from '+ 2 / -6 3' and similar expressions.

  Use C<< <expression> >> to match prefix expressions.

=end pod

role Grammar::Common::Expression::Infix::Actions {
	method operation:sym<plus>( $/ ) {
		make self.plus-operation( $/<lhs>.ast, $/<rhs>.ast );
	}
	method operation:sym<minus>( $/ ) {
		make self.minus-operation( $/<lhs>.ast, $/<rhs>.ast );
	}
	method operation:sym<times>( $/ ) {
		make self.times-operation( $/<lhs>.ast, $/<rhs>.ast );
	}
	method operation:sym<divide>( $/ ) {
		make self.divide-operation( $/<lhs>.ast, $/<rhs>.ast );
	}
	method operation:sym<modulo>( $/ ) {
		make self.modulo-operation( $/<lhs>.ast, $/<rhs>.ast );
	}
	method expression( $/ ) {
		if $/<value> {
			make $/<value>.ast;
		}
		elsif $/<operation> {
			make $/<operation>.made;
		}
	}
}

# vim: ft=perl6
