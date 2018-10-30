# Copyright (c) 2009 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking methods dealing with linear terms added in version 1.002

#########################

use v6;
use Test;
use Math::Polynomial;
plan 26;

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

my $p = Math::Polynomial.new(-6, -5, 2, 1);
my $q = $p * 3;
my $r = $p.new(-6, -3, 3);
my $cp = $p.new(7);
my $zp = $p.new;

my $p1 = Math::Polynomial.from-roots(-1, 2, -3);
ok(has_coeff($p1, -6, -5, 2, 1));       # 2

my $p2 = $p.from-roots();
ok(has_coeff($p2, 1));  # 3

my $p3 = $p.from-roots(-3);
ok(has_coeff($p3, 3, 1));       # 4

my $p4 = $r.mul-root(-3);
ok(has_coeff($p4, -18, -15, 6, 3));     # 5

my $p5 = $cp.mul-root(0);
ok(has_coeff($p5, 0, 7));       # 6

my $p6 = $zp.mul-root(7);
ok(has_coeff($p6));     # 7

my $p7 = $p.div-root(-3);
ok(has_coeff($p7, -2, -1, 1));  # 8

my $p8 = $p.div-root(-2);
ok(has_coeff($p8, -5, 0, 1));   # 9

my $p11 = $q.div-root(-3);
ok(has_coeff($p11, -6, -3, 3)); # 13

my $p13 = $q.div-root(-2);
ok(has_coeff($p13, -15, 0, 3)); # 15

my $p15 = $cp.div-root(-3);
ok(has_coeff($p15));    # 18

my $p17 = $zp.div-root(-3);
ok(has_coeff($p17));    # 21

my ($p19, $p20) = $p.divmod-root(-3);
ok(has_coeff($p19, -2, -1, 1)); # 23
ok(has_coeff($p20));    # 24

my ($p21, $p22) = $p.divmod-root(-2);
ok(has_coeff($p21, -5, 0, 1));  # 25
ok(has_coeff($p22, 4)); # 26

my ($p23, $p24) = $q.divmod-root(-3);
ok(has_coeff($p23, -6, -3, 3)); # 27
ok(has_coeff($p24));    # 28

my ($p25, $p26) = $q.divmod-root(-2);
ok(has_coeff($p25, -15, 0, 3)); # 29
ok(has_coeff($p26, 12));        # 30

my ($p27, $p28) = $cp.divmod-root(-3);
ok(has_coeff($p27));    # 31
ok(has_coeff($p28, 7)); # 32

my ($p29, $p30) = $zp.divmod-root(-3);
ok(has_coeff($p29));    # 33
ok(has_coeff($p30));    # 34

my $p32 = Math::Polynomial.from-roots();
ok(has_coeff($p32, 1)); # 37

my $p33 = Math::Polynomial.from-roots(1+0*i, 0+1*i, -1+0*i, 0-1*i);
ok(has_coeff($p33, -1, 0, 0, 0, 1));    # 38

