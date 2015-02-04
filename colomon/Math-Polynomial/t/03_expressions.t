# Copyright (c) 2007-2009 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking arithmetic operators and expressions.

#########################

use v6;
use Test;
plan 150;
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

my $p = Math::Polynomial.new(-0.25, 0, 1.25);
my $q = $p.new(-0.25, 0, 0.25);
my $r = $p.new(-1, 2);
my $mr = $p.new(-0.5, 1);
my $s = $p.new(0.5, 0.5);
my $c = $p.new(-0.5);
my $zp = $p.new;

nok !$p;              # !p is false
nok !$c;              # !c is false

ok $zp.degree < 0;    # zp is the zero polynomial
ok !$zp;              # !zp is true

my $bool = False;
while $p {
    $bool = True;
    last;
}
ok $bool;              # p is true;

$bool = True;
while $zp {
    $bool = False;
    last;
}
ok $bool;              # zp is false;

ok(!$p.is-zero);
ok($p.is-nonzero);
ok($zp.is-zero);
ok(!$zp.is-nonzero);

my $pp = $p.new(-0.25, 0, 1.25);

ok $p == $p;              # p == p
ok $p == $pp;             # p == pp
nok $p == $q;             # not p == q
nok $p == $r;             # not p == r

nok $p != $p;             # not p != p
nok $p != $pp;            # not p != pp
ok $p != $q;              # p != q
ok $p != $r;              # p != r

my $qq = -$p;
ok has_coeff($qq, 0.25, 0, -1.25);     # -p
$qq = -$zp;
ok has_coeff($qq);                     # -0

$qq = $p + $q;
ok(has_coeff($qq, -0.5, 0, 1.5));       # p + q
$qq = $p + $r;
ok(has_coeff($qq, -1.25, 2, 1.25));     # p + r
$qq = $r + $p;
ok(has_coeff($qq, -1.25, 2, 1.25));     # r + p
$qq = $p + $zp;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p + 0
$qq = $zp + $p;
ok(has_coeff($qq, -0.25, 0, 1.25));     # 0 + p

$qq = $p - $q;
ok(has_coeff($qq, 0, 0, 1));            # p - q
$qq = $p - $pp;
ok(has_coeff($qq));                     # p - p
$qq = $p - $r;
ok(has_coeff($qq, 0.75, -2, 1.25));     # p - r
$qq = $r - $p;
ok(has_coeff($qq, -0.75, 2, -1.25));    # r - p
$qq = $p - $zp;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p - 0
$qq = $zp - $p;
ok(has_coeff($qq, 0.25, 0, -1.25));     # 0 - p

$qq = $p * $q;
ok(has_coeff($qq, 1/16, 0, -3/8, 0, 5/16));     # p * q
$qq = $q * $p;
ok(has_coeff($qq, 1/16, 0, -3/8, 0, 5/16));     # q * p
$qq = $p * $r;
ok(has_coeff($qq, 0.25, -0.5, -1.25, 2.5));     # p * r
$qq = $r * $p;
ok(has_coeff($qq, 0.25, -0.5, -1.25, 2.5));     # r * p
$qq = $p * $c;
ok(has_coeff($qq, 1/8, 0, -5/8));               # p * c
$qq = $c * $p;
ok(has_coeff($qq, 1/8, 0, -5/8));               # c * p
$qq = $p * $zp;
ok(has_coeff($qq));                     # p * 0
$qq = $zp * $p;
ok(has_coeff($qq));                     # 0 * p

$qq = $p / $q;
ok(has_coeff($qq, 5));                  # p / q
$qq = $p / $r;
ok(has_coeff($qq, 5/16, 5/8));          # p / r
$qq = $p / $mr;
ok(has_coeff($qq, 5/8, 5/4));           # p / mr
$qq = $p / $c;
ok(has_coeff($qq, 0.5, 0, -2.5));       # p / c
# $qq = EVAL { $p / $zp };
# ok(!defined $qq);                       # not defined p / 0
# ok($@ =~ /division by zero polynomial/);
$qq = $r / $p;
ok(has_coeff($qq));                     # r / p
$qq = $r / $s;
ok(has_coeff($qq, 4));                  # r / s
$qq = $c / $p;
ok(has_coeff($qq));                     # c / p
$qq = $zp / $p;
ok(has_coeff($qq));                     # zp / p
# $qq = EVAL { $zp / $zp };
# ok(!defined $qq);                       # not defined 0 / 0
# ok($@ =~ /division by zero polynomial/);
# 
$qq = $p % $q;
ok(has_coeff($qq, 1));                  # p % q
$qq = $p % $r;
ok(has_coeff($qq, 1/16));               # p % r
$qq = $p % $mr;
ok(has_coeff($qq, 1/16));               # p % mr
$qq = $p % $c;
ok(has_coeff($qq));                     # p % c
# $qq = EVAL { $p % $zp };
# ok(!defined $qq);                       # not defined p % 0
# ok($@ =~ /division by zero polynomial/);
$qq = $r % $p;
ok(has_coeff($qq, -1, 2));              # r % p
$qq = $r % $s;
ok(has_coeff($qq, -3));                 # r % s
$qq = $c % $p;
ok(has_coeff($qq, -0.5));               # c % p
$qq = $zp % $p;
ok(has_coeff($qq));                     # zp % p
# $qq = EVAL { $zp % $zp };
# ok(!defined $qq);                       # not defined 0 % 0
# ok($@ =~ /division by zero polynomial/);

$qq = $p.mmod($q);
ok(has_coeff($qq, 0.25));               # p mmod q
$qq = $p.mmod($r);
ok(has_coeff($qq, 0.25));               # p mmod r
$qq = $p.mmod($mr);
ok(has_coeff($qq, 1/16));               # p mmod mr
$qq = $p.mmod($c);
ok(has_coeff($qq));                     # p mmod c
# $qq = EVAL { $p->mmod($zp) };
# ok(!defined $qq);                       # not defined p mmod 0
# ok($@ =~ /division by zero polynomial/);
$qq = $r.mmod($p);
ok(has_coeff($qq, -1, 2));              # r mmod p
$qq = $r.mmod($s);
ok(has_coeff($qq, -1.5));               # r mmod s
$qq = $c.mmod($p);
ok(has_coeff($qq, -0.5));               # c mmod p
$qq = $zp.mmod($p);
ok(has_coeff($qq));                     # zp mmod p
# $qq = EVAL { $zp->mmod($zp) };
# ok(!defined $qq);                       # not defined 0 mmod 0
# ok($@ =~ /division by zero polynomial/);

my $rr;
($qq, $rr) = $p.divmod($q);
ok(has_coeff($qq, 5));                  # p / q
ok(has_coeff($rr, 1));                  # p % q
($qq, $rr) = $p.divmod($r);
ok(has_coeff($qq, 5/16, 5/8));          # p / r
ok(has_coeff($rr, 1/16));               # p % r
($qq, $rr) = $p.divmod($mr);
ok(has_coeff($qq, 5/8, 5/4));           # p / mr
ok(has_coeff($rr, 1/16));               # p % mr
($qq, $rr) = $p.divmod($c);
ok(has_coeff($qq, 0.5, 0, -2.5));       # p / c
ok(has_coeff($rr));                     # p % c
# ($qq, $rr) = EVAL { $p->divmod($zp) };
# ok(!defined $qq);                       # not defined p / 0
# ok(!defined $rr);                       # not defined p % 0
# ok($@ =~ /division by zero polynomial/);
($qq, $rr) = $r.divmod($p);
ok(has_coeff($qq));                     # r / p
ok(has_coeff($rr, -1, 2));              # r % p
($qq, $rr) = $r.divmod($s);
ok(has_coeff($qq, 4));                  # r / s
ok(has_coeff($rr, -3));                 # r % s
($qq, $rr) = $c.divmod($p);
ok(has_coeff($qq));                     # c / p
ok(has_coeff($rr, -0.5));               # c % p
($qq, $rr) = $zp.divmod($p);
ok(has_coeff($qq));                     # zp / p
ok(has_coeff($rr));                     # zp % p
# ($qq, $rr) = EVAL { $zp->divmod($zp) };
# ok(!defined $qq);                       # not defined 0 / 0
# ok(!defined $rr);                       # not defined 0 % 0
# ok($@ =~ /division by zero polynomial/);

$qq = $p + 0;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p + 0
$qq = $p + 1;
ok(has_coeff($qq, 0.75, 0, 1.25));      # p + 1
$qq = 1 + $p;
ok(has_coeff($qq, 0.75, 0, 1.25));      # 1 + p

$qq = $p - 0;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p - 0
$qq = $p - 1;
ok(has_coeff($qq, -1.25, 0, 1.25));     # p - 1
$qq = 1 - $p;
ok(has_coeff($qq, 1.25, 0, -1.25));     # 1 - p

$qq = $p * 0;
ok(has_coeff($qq));                     # p * 0
$qq = $p * 1;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p * 1
$qq = $p * 2;
ok(has_coeff($qq, -0.5, 0, 2.5));       # p * 2

# $qq = EVAL { $p->div_const(0) };
# ok(!defined $qq);                       # not defined p / 0
# ok($@ =~ /division by zero/);
$qq = $p / 1;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p / 1
$qq = $p / 2;
ok(has_coeff($qq, -1/8, 0, 5/8));       # p / 2

$qq = $p ** 0;
ok(has_coeff($qq, 1));                  # p ** 0
$qq = $p ** 1;
ok(has_coeff($qq, -0.25, 0, 1.25));     # p ** 1
$qq = $p ** 2;
ok(has_coeff($qq, 1/16, 0, -5/8, 0, 25/16));    # p ** 2
$qq = $p ** 3;
ok(has_coeff($qq, -1/64, 0, 15/64, 0, -75/64, 0, 125/64));      # p ** 3
$qq = $c ** 0;
ok(has_coeff($qq, 1));                  # c ** 0
$qq = $c ** 1;
ok(has_coeff($qq, -0.5));               # c ** 1
$qq = $c ** 2;
ok(has_coeff($qq, 0.25));               # c ** 2
$qq = $c ** 3;
ok(has_coeff($qq, -1/8));               # c ** 3
$qq = $zp ** 0;
ok(has_coeff($qq, 1));                  # 0 ** 0
$qq = $zp ** 1;
ok(has_coeff($qq));                     # 0 ** 1
$qq = $zp ** 2;
ok(has_coeff($qq));                     # 0 ** 2
$qq = $zp ** 3;
ok(has_coeff($qq));                     # 0 ** 3
# $qq = EVAL { 3 ** $p };
# ok(!defined $qq);                       # not defined 3 ** p
# ok($@ =~ /wrong operand type/);
# $qq = EVAL { $p ** 0.5 };
# ok(!defined $qq);                       # not defined p ** 0.5
# ok($@ =~ /non-negative integer argument expected/);
# $qq = EVAL { $p ** $p };
# ok(!defined $qq);                       # not defined p ** p
# ok($@ =~ /non-negative integer argument expected/);

$qq = $p.pow-mod(0, $q);
ok(has_coeff($qq, 1));                  # p ** 0 % q
$qq = $p.pow-mod(1, $q);
ok(has_coeff($qq, 1));                  # p ** 1 % q
$qq = $p.pow-mod(2, $q);
ok(has_coeff($qq, 1));                  # p ** 2 % q
$qq = $p.pow-mod(3, $q);
ok(has_coeff($qq, 1));                  # p ** 3 % q
$qq = $p.pow-mod(0, $r);
ok(has_coeff($qq, 1));                  # p ** 0 % r
$qq = $p.pow-mod(1, $r);
ok(has_coeff($qq, 1/16));               # p ** 1 % r
$qq = $p.pow-mod(2, $r);
ok(has_coeff($qq, 1/256));              # p ** 2 % r
$qq = $p.pow-mod(0, $c);
ok(has_coeff($qq));                     # p ** 0 % c
$qq = $p.pow-mod(1, $c);
ok(has_coeff($qq));                     # p ** 1 % c
$qq = $p.pow-mod(2, $c);
ok(has_coeff($qq));                     # p ** 2 % c
# $qq = EVAL { $p->pow-mod(0, $zp) };
# ok(!defined $qq);                       # not defined p ** 0 % 0
# ok($@ =~ /division by zero polynomial/);
# $qq = EVAL { $p->pow-mod(1, $zp) };
# ok(!defined $qq);                       # not defined p ** 1 % 0
# ok($@ =~ /division by zero polynomial/);
# $qq = EVAL { $p->pow-mod(2, $zp) };
# ok(!defined $qq);                       # not defined p ** 2 % 0
# ok($@ =~ /division by zero polynomial/);
$qq = $r.pow-mod(0, $q);
ok(has_coeff($qq, 1));                  # r ** 0 % q
$qq = $r.pow-mod(1, $q);
ok(has_coeff($qq, -1, 2));              # r ** 1 % q
$qq = $r.pow-mod(2, $q);
ok(has_coeff($qq, 5, -4));              # r ** 2 % q
$qq = $r.pow-mod(3, $q);
ok(has_coeff($qq, -13, 14));            # r ** 3 % q
$qq = $c.pow-mod(0, $q);
ok(has_coeff($qq, 1));                  # c ** 0 % q
$qq = $c.pow-mod(1, $q);
ok(has_coeff($qq, -0.5));               # c ** 1 % q
$qq = $c.pow-mod(2, $q);
ok(has_coeff($qq, 0.25));               # c ** 2 % q
$qq = $zp.pow-mod(0, $q);
ok(has_coeff($qq, 1));                  # 0 ** 0 % q
$qq = $zp.pow-mod(1, $q);
ok(has_coeff($qq));                     # 0 ** 1 % q
$qq = $zp.pow-mod(2, $q);
ok(has_coeff($qq));                     # 0 ** 2 % q
# $qq = EVAL { $zp->pow-mod(0, $zp) };
# ok(!defined $qq);                       # not defined 0 ** 0 % 0
# ok($@ =~ /division by zero polynomial/);
# $qq = EVAL { $zp->pow-mod(1, $zp) };
# ok(!defined $qq);                       # not defined 0 ** 1 % 0
# ok($@ =~ /division by zero polynomial/);
# $qq = EVAL { $zp->pow-mod(2, $zp) };
# ok(!defined $qq);                       # not defined 0 ** 2 % 0
# ok($@ =~ /division by zero polynomial/);

$qq = $p.shift-up(3);
ok(has_coeff($qq, 0, 0, 0, -0.25, 0, 1.25));    # p << 3
$qq = $c.shift-up(3);
ok(has_coeff($qq, 0, 0, 0, -0.5));      # c << 3
$qq = $zp.shift-up(3);
ok(has_coeff($qq));                     # 0 << 3
$qq = $p.shift-up(0);
ok(has_coeff($qq, -0.25, 0, 1.25));     # p << 0
$qq = $zp.shift-up(0);
ok(has_coeff($qq));                     # 0 << 0

$qq = $p.shift-down(3);
ok(has_coeff($qq));                     # p >> 3
$qq = $p.shift-down(2);
ok(has_coeff($qq, 1.25));               # p >> 2
$qq = $p.shift-down(0);
ok(has_coeff($qq, -0.25, 0, 1.25));     # p >> 0
$qq = $zp.shift-down(2);
ok(has_coeff($qq));                     # 0 >> 2
$qq = $zp.shift-down(0);
ok(has_coeff($qq));                     # 0 >> 0

$pp = $p.new(11, 22, 33, 44, 55);
my $ok = True;
for ^7 -> $w {
    for ^7 -> $b {
        my @c = grep *.defined, (11, 22, 33, 44, 55)[$b..$b+$w-1];
        $qq = $pp.slice($b, $w);
        $ok ||= has_coeff($qq, @c);
    }
}
ok $ok;                                # slice

$qq = $p.nest($q);
ok(has_coeff($qq, -11/64, 0, -5/32, 0, 5/64));  # p(q)
$qq = $q.nest($p);
ok(has_coeff($qq, -15/64, 0, -5/32, 0, 25/64)); # q(p)
$qq = $p.nest($zp);
ok(has_coeff($qq, -0.25));              # q(0)
$qq = $zp.nest($p);
ok(has_coeff($qq));                     # 0(p)

nok $q.is-monic;                          # q is not monic
$pp = $q.monize;
ok(has_coeff($pp, -1, 0, 1));             # monize q
ok $pp.is-monic;                          # x**2-1 is monic
$qq = $pp.monize;
ok($qq == $pp);                           # monize monic pp
$qq = $c.monize;
ok(has_coeff($qq, 1));                    # monize c
$qq = $zp.monize;
ok(has_coeff($qq));                       # monize 0
nok $zp.is-monic;                         # zp is not monic

# assignment operators

$pp = Math::Polynomial.new(1, 10);
$qq = $pp;
$pp += $pp;
ok(has_coeff($pp, 2, 20));              # += working
ok(has_coeff($qq, 1, 10));              # += no side effects

$pp = $p && $q;
ok($pp == $q);                          # && operator long path

$pp = $zp && $q;
ok($pp == $zp);                         # && operator short path

$pp = $p || $q;
ok($pp == $p);                          # || operator short path

$pp = $zp || $q;
ok($pp == $q);                          # || operator long path

# # diagnostics
# 
# ok(10_000 == $Math::Polynomial::max_degree);
# 
# $Math::Polynomial::max_degree = 9;
# 
# $pp = $p->new(0, -1, 0, 1);
# $qq = EVAL { $pp ** 3 };
# ok(has_coeff($qq, 0, 0, 0, -1, 0, 3, 0, -3, 0, 1));
# $pp = $p->new(0, 4, 0, -5, 0, 1);
# $qq = EVAL { $pp ** 2 };
# ok(!defined($qq) && $@ && $@ =~ /exponent too large/);
# $qq = EVAL {
#     local $Math::Polynomial::max_degree;
#     $pp ** 2
# };
# ok(defined($qq) && $q->isa('Math::Polynomial'));
# 
# $qq = EVAL { $pp << 4 };
# ok(has_coeff($qq, 0, 0, 0, 0, 0, 4, 0, -5, 0, 1));
# $qq = EVAL { $pp << 5 };
# ok(!defined($qq) && $@ && $@ =~ /exponent too large/);
# $qq = EVAL {
#     local $Math::Polynomial::max_degree;
#     $pp << 5
# };
# ok(defined($qq) && $q->isa('Math::Polynomial'));
# 
# $qq = EVAL { $p->divmod($p) };
# ok(!defined($qq) && $@ && $@ =~ /array context required/);

