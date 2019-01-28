use v6.c;
unit class Test::Declare:ver<0.0.2>:auth<github:darrenf>;

=begin pod

=head1 NAME

Test::Declare - Declare common test scenarios as data.

=head2 CAVEAT

The author is a novice at Perl 6. Please be nice if you've stumbled across this and
have opinions to express. Furthermore I somehow failed to notice the pre-existence
of a Perl 5 C<Test::Declare>, to which this code is B<no relation>. Apologies for
any confusion; I renamed late in the day, being fed up with the length of my first
choice of C<Test::Declarative>.

=head1 SYNOPSIS

    use Test::Declare;

    use Module::Under::Test;

    declare(
        ${
            name => 'multiply',
            call => {
                class => Module::Under::Test,
                construct => \(2),
                method => 'multiply',
            },
            args => \(multiplicand => 4),
            expected => {
                return-value => 8,
            },
        },
        ${
            name => 'multiply fails',
            call => {
                class => Module::Under::Test,
                construct => \(2),
                method => 'multiply',
            },
            args => \(multiplicand => 'four'),
            expected => {
                dies => True,
            },
        },
        ${
            name => 'multiply fails',
            call => {
                class => Module::Under::Test,
                construct => \(2),
                method => 'multiply',
            },
            args => \(multiplicand => 8),
            expected => {
                # requires Test::Declare::Comparisons
                return-value => roughly(&[>], 10),
            },
        },
    );

=head1 DESCRIPTION

Test::Declare is an opinionated framework for writing tests without writing (much) code.
The author hates bugs and strongly believes in the value of tests. Since most tests
are code, they themselves are susceptible to bugs; this module provides a way to express
a wide variety of common testing scenarios purely in a declarative way.

=head1 USAGE

Direct usage of this module is via the exported subroutine C<declare>. The tests
within the distribution in L<t/|https://github.com/darrenf/p6-test-declare/tree/master/t>
can also be considered to be a suite of examples which exercise all the options
available.

=head2 declare(${ … }, ${ … })

C<declare> takes an array of hashes describing the test scenarios and expectations. Each hash should look like this:

=item1 name

The name of the test, for developer understanding in the TAP output.

=item1 call

A hash describing the code to be called.

=item2 class

The actual concrete class - not a string representation, and not an instance either.

=item2 method

String name of the method to call.

=item2 construct

If required, a L<Capture|https://docs.perl6.org/type/Capture.html> of the arguments to the class's C<new> method.

=item1 args

If required, a L<Capture|https://docs.perl6.org/type/Capture.html> of the arguments to the instance's method.

=item1 expected

A hash describing the expected behaviour when the method gets called.

=item2 return-value

The return value of the method, which will be compared to the actual return value via C<eqv>.

=item2 lives/dies/throws

C<lives> and C<dies> are booleans, expressing simply whether the code should work or not. C<throws> should be an Exception type.

=item2 stdout/stderr

Strings against which the method's output/error streams are compared, using C<eqv> (i.e. not a regex).

=head1 SEE ALSO

Elsewhere in this distribution:

=begin item

C<Test::Declare::Comparisons> - for fuzzy matching including some naive/rudimentary
attempts at copying the L<Test::Deep|https://metacpan.org/pod/Test::Deep> interface
where Perl 6 does not have it builtin.

=end item

=begin item

L<Test::Declare::Suite|https://github.com/darrenf/p6-test-declare/tree/master/lib/Test/Declare/Suite.pm6>
- for a role which bundles tests together against a common class/method, to reduce repetition.

=end item

Used by the code here:

=item L<Test|https://github.com/rakudo/rakudo/blob/master/lib/Test.pm6>

=item L<IO::Capture::Simple|https://github.com/sergot/IO-Capture-Simple>

Conceptually or philosophically similar projects:

=item Perl 5's C<Test::Declare|https://metacpan.org/pod/Test::Declare> (oops, didn't see the name clash when I started)

=item Perl 5's C<Test::Spec|https://metacpan.org/pod/Test::Spec>

=item L<TestML|http://testml.org/>

And of course:

=item L<Perl 6|https://perl6.org/>

=head1 AUTHOR

Darren Foreman <81590+darrenf@users.noreply.github.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Darren Foreman

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

use IO::Capture::Simple;
use Test;

use Test::Declare::Callable;
use Test::Declare::Expectations;
use Test::Declare::Result;

has Str $.name is required;
has %.expected is required;
has %.call is required;
has Capture $.args;
has Bool $.debug = False;

has $!callable = Test::Declare::Callable.new(|self.call);
has $!expectations = Test::Declare::Expectations.new(|self.expected);
has $!result = Test::Declare::Result.new();

method execute() {
    $!callable.args = $!args if $!args;
    diag sprintf('calling %s.%s', $!callable.class.^name, $!callable.method) if self.debug;
    try {
        CATCH {
            default {
                $!result.status = 'died';
                $!result.exception = $_;
            }
        }
        my ($stdout, $stderr, $stdin) = capture {
            $!result.return-value = $!callable.call();
        }
        $!result.streams = stdout => $stdout, stderr => $stderr, stdin => $stdin;
    }
}
method test-streams() {
    if ($!expectations.stdout) {
        ok(
            $!expectations.stdout.compare(
                $!result.streams{'stdout'}
            ),
            self.name ~ ' - stdout'
        );
    }
    if ($!expectations.stderr) {
        ok(
            $!expectations.stderr.compare(
                $!result.streams{'stderr'}
            ),
            self.name ~ ' - stderr'
        );
    }
}
method test-status() {
    if ($!expectations.lives) {
        ok(!$!result.status, self.name ~ ' lived');
    }
    else {
        if ($!expectations.dies) {
            is($!result.status, 'died', self.name ~ ' - died');
        }
        if ($!expectations.throws) {
            isa-ok(
                $!result.exception,
                $!expectations.throws,
                sprintf(
                    '%s - threw a(n) %s (actually: %s)',
                    self.name,
                    $!expectations.throws,
                    $!result.exception.^name,
                ),
            );
        }
    }
}

method test-return-value() {
    if my $rv = $!expectations.return-value {
        my $test-description = sprintf('%s - return value', self.name);
        if self.debug {
            $test-description ~= sprintf(
                ' (%s %s %s)',
                $!result.return-value.Str,
                $rv.op.name,
                $rv.rhs.Str,
            );
        }
        ok($rv.compare($!result.return-value),$test-description);
    }
    elsif $!result.return-value && self.debug {
        diag self.name ~ ' - got untested return value ->';
        diag '   ' ~ $!result.return-value;
    }
    if my $mut = $!expectations.mutates {
        ok(
            $mut.compare(|$!callable.args),
            sprintf(
                '%s - mutates',
                self.name,
            ),
        );
    }
}

sub declare(*@tests where {$_.all ~~Hash}) is export {
    plan @tests.Int;
    for @tests -> %test {
        my $td = Test::Declare.new(|%test);
        subtest $td.name => sub {
            plan $td.expected.Int;
            $td.execute();
            $td.test-streams();
            $td.test-status();
            $td.test-return-value();
        }
    }
}
