# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

=begin pod

=head1 NAME

Test::Builder::Plan - manages the plan set for the test harness

Test::Builder::NoPlan - manages the pseudo-plan when one isn't set

=head1 DESCRIPTION

The C<Test::Builder::Plan> class manages the plan used by the test harness.
It contains the number of expected tests and formats the headers and footers
used in reporting test results.

Conversely, the C<Test::Builder::NoPlan> class is used when a plan is not
explicitly set.

B<NOTE:> The C<Test::Builder::Plan> C<Test::Builder::NoPlan> classes should not
be used directly. There are only meant to be used internally.

=head1 USE

=head2 Public Attributes

=over 4

=item B<$.expected>

The expected number of tests to run.

=back

=head2 Object Initialization

=over 4

=item B<new()>

Returns a new C<Test::Builder::Plan> or C<Test::Builder::NoPlan> instance.

=back

=head2 Public Methods

=over 4

=item B<header()>

Returns a string to be used as the header; displayed before any test results.

=item B<footer()>

Returns a string to be used as the footer; displayed after all tests have been
run.

=back

=head1 SEE ALSO

L<http://testanything.org>

=head1 ACKNOWLEDGEMENTS

C<Test::Builder> was largely inspired by chromatic's work on the old
C<Test::Builder> module for Pugs.

Additionally, C<Test::Builder> is based on the Perl 5 module of the same name
also written by chromatic <chromatic@wgz.org> and Michael G. Schwern
<schwern@pobox.com>.

=head1 COPYRIGHT

Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see LICENSE or visit 
<http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.

=end pod

#= Generic role for common methods
role Test::Builder::Plan::Generic {
    #= Returns generic header
    method header() returns Str {
        return '';
    }

    #= Returns generic footer
    method footer(Int $ran) returns Str {
        return "1..$ran";
    }
}

#= Manages the plan set for the test harness
class Test::Builder::Plan does Test::Builder::Plan::Generic {
    has Int $.expected is rw;    #= Number of tests that "should" be run

    submethod BUILD(:$!expected = 0) {
        die 'Invalid or missing plan!' unless self.expected.defined;
    }

    #= Returns string to be displayed before tests are run
    method header() returns Str {
        return "1..$.expected";
    }

    #= Returns string to be used as footer in final report
    method footer(Int $ran) returns Str {
        # Determine whether to use past or present tense in message
        my Str $s = $.expected == 1 ?? '' !! 's';

        return $ran == $.expected
            ?? ''
            !! "\# Looks like you planned $.expected test$s but ran $ran.";
    }
}

#= Manages the pseudo-plan when one isn't set
class Test::Builder::NoPlan does Test::Builder::Plan::Generic { }

# vim: ft=perl6

