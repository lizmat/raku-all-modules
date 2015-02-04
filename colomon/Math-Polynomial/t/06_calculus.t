# Copyright (c) 2007-2009 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking calculus operators.

#########################

use v6;
use Test;
plan 4;
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

my $p = Math::Polynomial.new(0, -5, -5, 5, 5, 1);
my $pd = $p.differentiate;
ok(has_coeff($pd, -5, -10, 15, 20, 5));

my $pi = $pd.integrate;
ok(has_coeff($pi, 0, -5, -5, 5, 5, 1));

$pi = $pd.integrate(-1);
ok(has_coeff($pi, -1, -5, -5, 5, 5, 1));

my $a = $pd.definite_integral(0, 1);
ok($a == 1);
