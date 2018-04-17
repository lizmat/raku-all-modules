use v6.c;

use List::MoreUtils <pairwise>;
use Test;

plan 11;

my @a = 1, 2, 3, 4, 5;
my @b = 2, 4, 6, 8, 10;
my @c = pairwise -> $a, $b { $a + $b }, @a, @b;
is-deeply @c, [3, 6, 9, 12, 15], "pw1";

@c = pairwise -> $a, $b { $a * $b }, @a, @b;
is-deeply @c, [2, 8, 18, 32, 50], "pw2";

# Did we modify the input arrays?
is-deeply @a, [1, 2, 3, 4, 5],  "pw3";
is-deeply @b, [2, 4, 6, 8, 10], "pw4";

# $a and $b should be aliases: test
@b = @a = 1, 2, 3;
@c = pairwise -> $a is rw, $b is rw { $a++; $b *= 2 }, @a, @b;
is-deeply @a, [2, 3, 4], "pw5";
is-deeply @b, [2, 4, 6], "pw6";
is-deeply @c, [2, 4, 6], "pw7";

# sub returns more than two items
@a = 1, 1, 2, 3, 5;
@b = 2, 3, 5, 7, 11, 13;
@c = pairwise -> $a, $b { |($a xx $b) }, @a, @b;
is-deeply @c, [|(1 xx 2),|(1 xx 3),|(2 xx 5),|(3 xx 7),|(5 xx 11),|(Any xx 13)],
  "pw8";
is-deeply @a, [1, 1, 2, 3, 5], "pw9";
is-deeply @b, [2, 3, 5, 7, 11, 13], "pwX";

@a = <a b c>;
@b = <1 2 3>;
@c = pairwise -> $a, $b { |($a, $b) }, @a, @b;
is-deeply @c, [<a 1 b 2 c 3>], "pw map";

# vim: ft=perl6 expandtab sw=4
