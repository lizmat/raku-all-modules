# Copyright (c) 2007-2010 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking basic constructors and attribute accessors.

#########################

use v6;
use Test;
plan 94;
use Math::Polynomial;

#########################

my @samples = (
    [[],           [],           [0],         ],
    [[0],          [],           [0],         ],
    [[5],          [5],          [5],         ],
    [[5, 0, 0],    [5],          [5],         ],
    [[2, 0, 0, 8], [2, 0, 0, 8], [2, 0, 0, 8],],
);

for @samples -> $sample {
    my @arg  = $sample[0].flat;
    my @res1 = $sample[1].flat;
    my $p = Math::Polynomial.new(@arg);
    ok $p.defined, '$p is defined';
    isa_ok $p, Math::Polynomial, '$p is a Math::Polynomial';
    is $p.coefficients, @res1, '$p has the proper coefficients';
}

my $sp = Math::Polynomial.new(-1, 2, 3);
for @samples -> $sample {
    my @arg  = $sample[0].flat;
    my @res1 = $sample[1].flat;
    my $p = $sp.new(@arg);
    ok $p.defined, '$p is defined';
    isa_ok $p, Math::Polynomial, '$p is a Math::Polynomial';
    is $p.coefficients, @res1, '$p has the proper coefficients';
}
 
@samples = (
    [[0],     [1]],
    [[1],     [0, 1]],
    [[4],     [0, 0, 0, 0, 1]],
    [[0, 10], [10]],
    [[1, 11], [0, 11]],
    [[2, 13], [0, 0, 13]],
    [[0, 0],  []],
    [[2, 0],  []],
);

for @samples -> $sample {
    my @arg  = $sample[0].flat;
    my @res = $sample[1].flat;
    my $p = Math::Polynomial.monomial(|@arg);
    ok $p.defined, '$p is defined';
    isa_ok $p, Math::Polynomial, '$p is a Math::Polynomial';
    is $p.coefficients, @res, '$p has the proper coefficients';
}

for @samples -> $sample {
    my @arg  = $sample[0].flat;
    my @res = $sample[1].flat;
    my $p = $sp.monomial(|@arg);
    ok $p.defined, '$p is defined';
    isa_ok $p, Math::Polynomial, '$p is a Math::Polynomial';
    is $p.coefficients, @res, '$p has the proper coefficients';
}

ok(0 == $sp.coeff-zero);
ok(1 == $sp.coeff-one);
ok(2 == $sp.degree);

my $zp = $sp.new;
ok(0 == $zp.coeff-zero);
ok(1 == $zp.coeff-one);
ok -Inf == $zp.degree;
 
$sp = $sp.new(-1, -2, 1);
@samples = (
    [-1, 2],
    [0, -1],
    [1, -2],
    [2, -1],
    [3, 2],
);

for @samples -> $sample {
    is $sp.evaluate($sample[0]), $sample[1], '$sp evaluates properly for ' ~ $sample[0];
    is $zp.evaluate($sample[0]), 0, '$zp evaluates properly for ' ~ $sample[0];
}

# # diagnostics
# 
# $Math::Polynomial::max_degree = 10;
# 
# my $q = EVAL { Math::Polynomial->monomial(10, 20) };
# ok($q && $q->isa('Math::Polynomial'));
# 
# $q = EVAL { Math::Polynomial->monomial(11, 1) };
# ok(!defined($q) && $@ && $@ =~ /exponent too large/);
# 
# $q = EVAL {
#     local $Math::Polynomial::max_degree;
#     Math::Polynomial->monomial(11, 1)
# };
# ok($q && $q->isa('Math::Polynomial'));
# 
# $q = EVAL { $sp->monomial(10, 20) };
# ok($q && $q->isa('Math::Polynomial'));
# 
# $q = EVAL { $sp->monomial(11, 1) };
# ok(!defined($q) && $@ && $@ =~ /exponent too large/);
# 
# $q = EVAL {
#     local $Math::Polynomial::max_degree;
#     $sp->monomial(11, 1)
# };
# ok($q && $q->isa('Math::Polynomial'));
# 
# $q = Math::Polynomial->new(0, 1);
# my $c = EVAL { $q->coeff };
# ok(
#     !defined($c) && $@ &&
#     $@ =~ /array context required if called without argument/
# );
# 
# $c = EVAL { $q->coefficients };
# ok(!defined($c) && $@ && $@ =~ /array context required/);
