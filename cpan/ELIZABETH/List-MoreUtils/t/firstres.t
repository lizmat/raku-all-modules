use v6.c;

use List::MoreUtils <firstres first_result>;
use Test;

plan 4;

ok &firstres =:= &first_result, 'is firstres the same as first_result';

is firstres( { 2 * $_ if $_ > 5 }, (4 .. 9) ), 12, "right first result";
is firstres( { $_ > 3 }, (1 .. 4) ), True, 'did we get boolean result';
is firstres( { $_ > 5 }, (1 .. 4) ), Nil, 'did we get no result';

# vim: ft=perl6 expandtab sw=4
