use v6.c;

use List::MoreUtils <firstidx first_index>;
use Test;

plan 5;

ok &firstidx =:= &first_index, 'is firstidx the same as first_index';

my @list = 1 .. 10000;

is firstidx( { $_ >= 5000 }, @list), 4999,  "firstidx";
is firstidx( { not .defined }, @list), -1, "invalid firstidx";
is firstidx( { .defined }, @list), 0, "real firstidx";
is firstidx( { True }, ()), -1, "empty firstidx";

# vim: ft=perl6 expandtab sw=4
