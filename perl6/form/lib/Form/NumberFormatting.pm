module Form::NumberFormatting;

use Form::TextFormatting;

=begin pod

=head1 Form::NumberFormatting

Utility functions for formatting numbers in Form.pm.

=end pod


=begin pod

=head2 obtain-number-parts(Real $number)

Splits out the integer and non-integer components of a number. Returns a list of int part, float part.

=end pod

our sub obtain-number-parts(Real $number) {
	my $ints = $number.Int;
	my $fractions = $number - $ints;

	# it's much easier if we have this as an integer as it's rendered separately to the ints
	$fractions.=abs;
	$fractions *= 10 while $fractions.Int != $fractions;

    return ($ints, $fractions);
}

=begin pod

=end pod


# vim: ft=perl6 sw=4 ts=4 noexpandtab

