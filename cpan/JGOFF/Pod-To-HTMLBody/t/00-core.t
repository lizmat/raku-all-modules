use v6;
use Pod::To::HTMLBody;
use Test;

=begin pod
Lorem ipsum
=end pod

ok Pod::To::HTMLBody.render( $=pod[0] );

done-testing;

# vim: ft=perl6
