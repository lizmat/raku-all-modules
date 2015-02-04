# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

# TODO Define Test::Builder::Exception
# TODO Replace die() with fail()

=begin pod

=head1 NAME

Test::Builder - flexible framework for building TAP test libraries

=head1 SYNOPSIS

=begin code

    my $tb = Test::Builder.new;

    $tb.plan(2);

    $tb.ok(1, 'This is a test');
    $tb.ok(1, 'This is another test');

    $tb.done;

=end code

=head1 DESCRIPTION

C<Test::Builder> is meant to serve as a generic backend for test libraries. Put
differently, it provides the basic "building blocks" and generic functionality
needed for building your own application-specific TAP test libraries.

C<Test::Builder> conforms to the Test Anything Protocol (TAP) specification.

=head1 USE

=head2 Object Initialization

=over 4

=item B<new()>

Returns the C<Test::Builder> singleton object.

The C<new()> method only returns a new object the first time that it's called.
If called again, it simply returns the same object. This allows multiple
modules to share the global information about the TAP harness's state.

Alternatively, if a singleton object is too limiting, you can use the
C<create()> method instead.

=item B<create()>

Returns a new C<Test::Builder> instance.

The C<create()> method should only be used under certain circumstances. For
instance, when testing C<Test::Builder>-based modules. In all other cases, it
is recommened that you stick to using C<new()> instead.

=back

=head2 Implementing Tests

The following methods are responsible for performing the actual tests.

All methods take an optional string argument describing the nature of the test.

=over 4

=item B<plan(Int $tests)>

Declares how many tests are going to be run.

If called as C<.plan(*)>, then a plan will not be set. However, it is your job
to call C<done()> when all tests have been run.

=item B<ok(Mu $test, Str $description)>

Evalutes C<$test> in a boolean context. The test will pass if the expression
evalutes to C<Bool::True> and fail otherwise.

=item B<nok(Mu $test, Str $description)>

The antithesis of C<ok()>. Evalutes C<$test> in a boolean context. The test
will pass if the expression evalutes to C<Bool::False> and fail otherwise.

=back

=head2 Modifying Test Behavior

=over 4

=item B<todo(Str $reason, Int $count)>

Marks the next C<$count> tests as failures but ignores the fact. Test
execution will continue after displaying the message in C<$reason>.

It's important to note that even though the tests are marked as failures, they
will still be evaluated. If a test marked with C<todo()> in fact passes, a
warning message will be displayed.

# TODO The todo() method doesn't actually does this yet but I want it to

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

use Test::Builder::Test;
use Test::Builder::Plan;
use Test::Builder::Output;

class Test::Builder { ... };

#= Global Test::Builder singleton object
my Test::Builder $TEST_BUILDER;

class Test::Builder:<soh_cah_toa 0.0.1> {
    #= Stack containing results of each test
    has Test::Builder::Test          @!results;

    #= Sets up number of tests to rune
    has Test::Builder::Plan::Generic $!plan;

    #= Handles all output operations
    has Test::Builder::Output        $!output handles 'diag';

    #= Specifies whether or not .done() has been called
    has Bool                         $.done_testing is rw;

    #= Returns the Test::Builder singleton object
    method new() {
        return $TEST_BUILDER //= self.create;
    }

    #= Returns a new Test::Builder instance
    method create() {
        return $?CLASS.bless(*);
    }

    submethod BUILD(Test::Builder::Plan   $!plan?,
                    Test::Builder::Output $!output = Test::Builder::Output.new) { }

    #= Declares that no more tests need to be run
    method done() {
        $.done_testing = Bool::True;

        my $footer = $!plan.footer(+@!results);
        $!output.write($footer) if $footer;
    }

    #= Declares the number of tests to run
    multi method plan(Int $tests) {
        die 'Plan already set!' if $!plan;

        $!plan = Test::Builder::Plan.new(:expected($tests));
    }

    #= Declares that the number of tests is unknown
    multi method plan(Whatever $tests) {
        die 'Plan already set!' if $!plan;

        $!plan = Test::Builder::NoPlan.new;
    }

    # TODO Implement skip_all and no_plan
    multi method plan(Str $explanation) { ... }

    #= Default candidate for arguments of the wrong type
    multi method plan(Any $any) {
        die 'Unknown plan!';
    }

    #= Tests the first argument for boolean truth
    method ok(Mu $test, Str $description= '') {
        self!report_test(Test::Builder::Test.new(:number(self!get_test_number),
                                                 :passed(?$test),
                                                 :description($description)));

        return $test;
    }

    #= Tests the first argument for boolean false
    method nok(Mu $test, Str $description= '') {
        self!report_test(Test::Builder::Test.new(:number(self!get_test_number),
                                                 :passed(!$test),
                                                 :description($description)));

        return $test;
    }

    #= Verifies that the first two arguments are equal
    method is(Mu $got, Mu $expected, Str $description= '') {
        my Bool $test = ?$got eq ?$expected;

        # Display verbose report unless test passed
        if $test {
            self!report_test(Test::Builder::Test.new(
                :number(self!get_test_number),
                :passed($test),
                :description($description)));
        }
        else {
            self!report_test(Test::Builder::Test.new(
                    :number(self!get_test_number),
                    :passed($test),
                    :description($description)),
                :verbose({ got => $got, expected => $expected }));
        }

        return $test;
    }

    #= Verifies that the first two arguments are not equal
    method isnt(Mu $got, Mu $expected, Str $description= '') {
        my Bool $test = ?$got ne ?$expected;

        # Display verbose report unless test passed
        if $test {
            self!report_test(Test::Builder::Test.new(
                :number(self!get_test_number),
                :passed($test),
                :description($description)));
        }
        else {
            self!report_test(Test::Builder::Test.new(
                    :number(self!get_test_number),
                    :passed($test),
                    :description($description)),
                :verbose({ got => $got, expected => $expected }));
        }

        return $test;
    }

    #= Marks a given number of tests as failures
    method todo(Mu $todo, Str $description = '', Str $reason = '') {
        self!report_test(Test::Builder::Test.new(:todo(Bool::True),
                                                 :number(self!get_test_number),
                                                 :reason($reason),
                                                 :description($description)));

        return $todo;
    }

    #= Displays the results of the given test
    method !report_test(Test::Builder::Test::Generic $test, :%verbose) {
        die 'No plan set!' unless $!plan;

        @!results.push($test);

        $!output.write($test.report);
        $!output.diag($test.verbose_report(%verbose)) if %verbose;
    }

    #= Returns the current test number
    method !get_test_number() {
        return +@!results + 1;
    }
}

END { $TEST_BUILDER.done unless $TEST_BUILDER.done_testing }

# vim: ft=perl6

