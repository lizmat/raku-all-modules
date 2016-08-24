#!/usr/bin/env perl6

unit module Test::Deeply::Relaxed:ver<0.1.1.dev1>:auth<github:ppentchev>;

use v6.c;

use Test;

sub get-iterator(Iterable:D $seq, Bool:D $cache) returns Iterator:D
{
	$cache && $seq ~~ PositionalBindFailover
	    ?? $seq.cache.iterator
	    !! $seq.iterator
}

sub check-deeply-relaxed($got, $expected, Bool:D :$cache) returns Bool:D
{
	given $expected {
		when Baggy {
			return False unless $got ~~ Baggy;
			return $got ≼ $expected && $got ≽ $expected;
		}

		when Setty {
			return False unless $got ~~ Set;
			return !($got ⊖ $expected);
		}

		when Associative {
			return False unless $got ~~ Associative &&
			    $got !~~ Setty && $got !~~ Baggy;
			return False if set($got.keys) ⊖ set($expected.keys);
			return ?( $got.keys.map(
			    { check-deeply-relaxed($got{$_}, $expected{$_}, :$cache) }
			    ).all);
		}
		
		when Array {
			return False unless $got ~~ Array;
			return False unless $got.elems == $expected.elems;
			return ?( ($got.list Z $expected.list).map(-> ($g, $e)
			    { check-deeply-relaxed($g, $e, :$cache) }
			    ).all);
			return True;
		}

		when Iterable {
			return False unless $got ~~ Iterable &&
			    $got !~~ Array && $got !~~ Associative;
			my $i-exp = get-iterator($expected, $cache);
			my $i-got = get-iterator($got, $cache);
			loop {
				my $v-exp := $i-exp.pull-one;
				my $v-got := $i-got.pull-one;
				if $v-exp =:= IterationEnd {
					return $v-got =:= IterationEnd;
				} elsif $v-got =:= IterationEnd {
					return False;
				}
				return False unless check-deeply-relaxed($v-got, $v-exp, :$cache);
			}
		}
		
		when Str {
			return False unless $got ~~ Str;
			return $got eq $expected;
		}
		
		when Bool {
			return False unless $got ~~ Bool;
			return ?$got == ?$expected;
		}

		when Numeric {
			return False unless $got ~~ Numeric && $got !~~ Bool;
			return $got == $expected;
		}
		
		default {
			return False;
		}
	}
}

sub test-deeply-relaxed($got, $expected, Bool:D :$whine = True, Bool:D :$cache) returns Bool:D is export(:test)
{
	return True if check-deeply-relaxed($got, $expected, :$cache);
	if $whine {
		try diag "Expected:\n\t$expected.perl()\nGot:\n\t$got.perl()\n";
		diag 'Could not output the mismatched deeply-relaxed values' if $!;
	}
	return False;
}

sub is-deeply-relaxed($got, $expected, $name = Str, Bool:D :$cache = False) is export
{
	ok test-deeply-relaxed($got, $expected, :$cache), $name;
}

sub isnt-deeply-relaxed($got, $expected, $name = Str, Bool:D :$cache = False) is export
{
	nok test-deeply-relaxed($got, $expected, :$cache, :!whine), $name;
}

=begin pod

=head1 NAME

Test::Deeply::Relaxed - Compare two complex data structures loosely

=head1 SYNOPSIS

=begin code
    use Test;
    use Test::Deeply::Relaxed;

    is-deeply-relaxed 'foo', 'foo';
    isnt-deeply-relaxed 'foo', 'bar';

    is-deeply-relaxed 5, 5;
    isnt-deeply-relaxed 5, '5';

    is-deeply-relaxed [1, 2, 3], Array[Int:D].new(1, 2, 3);

    is-deeply-relaxed {:a("foo"), :b("bar")}, Hash[Str:D].new({ :a("foo"), :b("bar") });

    # And now for the one that made me write this...
    my Array[Str:D] %opts;
    %opts<v> = Array[Str:D].new("v", "v");
    %opts<i> = Array[Str:D].new("foo.txt", "bar.txt");
    is-deeply-relaxed %opts, {:v([<v v>]), :i([<foo.txt bar.txt>]) };

    # It works with weirder types, too
    is-deeply-relaxed bag(<a b a a>), { a => 3, b => 1 }.Mix;
    isnt-deeply-relaxed bag(<a b a a>), { a => 2, b => 1 }.Mix;
    isnt-deeply-relaxed bag(<a b a a>), { a => 3, b => 1.5 }.Mix;
=end code

=head1 DESCRIPTION

The C<Test:::Deeply::Relaxed> module provides the C<is-deeply-relaxed()>
and C<isnt-deeply-relaxed()> functions that do not check the state of
mind of the passed objects, but instead compare their structure in depth
similarly to C<is-deeply()>, but a bit more loosely.  In particular, they
ignore the differences between typed and untyped collections, e.g. they
will consider an array and an explicit C<Array[Str:D]> to be the same if
the strings contained within are indeed the same.

=head1 FUNCTIONS

=begin item1
sub is-deeply-relaxed

    sub is-deeply-relaxed($got, $expected, $name = Str, Bool:D :$cache = False)

Compare the two data structures in depth similarly to C<is-deeply()>,
but a bit more loosely.

If the C<:cache> flag is specified, the cache of values will be used for
any iterable objects that support it.  This allows the caller to later
examine the sequences further.

Current API available since version 0.1.0.
=end item1

=begin item1
sub isnt-deeply-relaxed

    sub isnt-deeply-relaxed($got, $expected, $name = Str, Bool:D :$cache = False)

The opposite of C<is-deeply-relaxed()> - fail if the two structures
are loosely the same.

Current API available since version 0.1.0.
=end item1

=head1 AUTHOR

Peter Pentchev <L<roam@ringlet.net|mailto:roam@ringlet.net>>

=head1 COPYRIGHT

Copyright (C) 2016  Peter Pentchev

=head1 LICENSE

The Test::Deeply::Relaxed module is distributed under the terms of
the Artistic License 2.0.  For more details, see the full text of
the license in the file LICENSE in the source distribution.

=end pod
