use v6.c;

use List::MoreUtils <qsort>;
use Test;

plan 2;

my @ltn_asc = <2 3 5 7 11 13 17 19 23 29 31 37>;
my @ltn_des = reverse @ltn_asc;
my @l;

@l = @ltn_des;
qsort -> $a, $b { $a <=> $b }, @l;
is-deeply @l, @ltn_asc, "sorted ascending";

@l = @ltn_asc;
qsort -> $a, $b { $b <=> $a }, @l;
is-deeply @l, @ltn_des, "sorted descending";
# vim: ft=perl6 expandtab sw=4
