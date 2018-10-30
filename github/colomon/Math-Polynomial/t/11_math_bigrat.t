# Copyright (c) 2007-2010 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking coefficient space compatibility with Math::BigRat.

#########################

use v6;
use Test;
use Math::Polynomial;

plan 7;

my $c0 = FatRat.new(-1, 2);
my $c1 = FatRat.new(0);
my $c2 = FatRat.new(3, 2);
my $p  = Math::Polynomial.new($c0, $c1, $c2);

my $x1 = FatRat.new(1, 2);
my $x2 = FatRat.new(2, 3);
my $x3 = FatRat.new(1);
my $y1 = FatRat.new(-1, 8);
my $y2 = FatRat.new(1, 6);
my $y3 = FatRat.new(1);

ok $y1 == $p.evaluate($x1);
ok $y2 == $p.evaluate($x2);
ok $y3 == $p.evaluate($x3);

my $q = $p.interpolate([$x1, $x2, $x3], [$y1, $y2, $y3]);
ok $p == $q;

my $x = $p.monomial(1);
my $y = $x - $p.coeff-one;
isa-ok $y, Math::Polynomial, '$y is indeed a Math::Polynomial';
ok 1 == $y.degree;
ok $p.coeff-zero == $y.evaluate($x3);

# Seems like maybe there should be a test of the type of $y's coefficients here?

