use v6;

=begin pod

=head1 Grammar::Common

L<Grammar::Common> gives you a library of common grammar roles to use in
your own code, from simple numbers and strings to vaidation tools.

=head1 Synopsis

    use Grammar::Common;

    grammar PostScript {
        also does Grammar::Common::Expression::Prefix;

        token number { <[ - + ]>? <[ 0 .. 9 ]>+ }

        rule TOP { 'dup' <expression> }
    }

    my $x = PostScript.parse( 'dup + 1 3' );

=head1 Documentation

=head2 grammar roles

  =item L<Expression::Prefix>

  Match '+ 2 / -6 3'

  =item double-quote-string

  Match a double-quote string with optional escaped double quotes.

=end pod

# vim: ft=perl6
