# Copyright (c) 2007-2009 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking Lagrange interpolation.

#########################

use v6;
use Test;
plan 9;
use Math::Polynomial;

#########################

sub has_coeff($p, *@desired-coefficients) {
    unless $p ~~ Math::Polynomial {
        say "# expected Math::Polynomial object, got { $p.WHAT }";
        return False;
    }

    return True if @desired-coefficients == 0 && $p.is-zero; # special case while we figure out what to do

    my @coeff = $p.coefficients;
    if @coeff != @desired-coefficients || any(@coeff Z!= @desired-coefficients) {
        say '# expected coefficients (',
            @desired-coefficients.join(", "),
            '), got (',
            @coeff.join(", "),
            ")";
        return False;
    }
    return True;
}

my $p = Math::Polynomial.interpolate([-1..2], [0, 1, 2, -9]);
ok(has_coeff($p, 1, 3, 0, -2));

my $q = $p.interpolate([0..3], [3, 0, 0, 3]);
ok(has_coeff($q, 3, -4.5, 1.5));

my $c = $p.interpolate([0], [1]);
ok(has_coeff($c, 1));

my $z0 = $p.interpolate([], []);
ok(has_coeff($z0));

my $z1 = $p.interpolate([1, 2], [0, 0]);
ok(has_coeff($z1));

my $z2 = Math::Polynomial.interpolate([], []);
ok(has_coeff($z2));

dies-ok { $p.interpolate([1], [2, 3]) }, "Arrays must be equal length";
# ok($@ =~ /usage/);

dies-ok { $p.interpolate([1], 2) }, "Both arguments must be arrays";
# ok($@ =~ /usage/);
 
dies-ok { $p.interpolate(1, [2]) }, "Both arguments must be arrays";
# ok($@ =~ /usage/);

# $r = EVAL { $p.interpolate([1, 1], [2, 2]) };
# ok(!defined $r);
# ok($@ =~ /x values not disjoint/);

