use v6.c;

use List::MoreUtils <lastres last_result>;
use Test;

plan 4;

ok &lastres =:= &last_result, 'is lastres the same as last_result';

is lastres( { 2 * $_ if $_ > 5 }, (4 .. 9) ), 18, "right last result";
is lastres( { $_ > 3 }, (1 .. 4) ), True, 'did we get boolean result';
is lastres( { $_ > 5 }, (1 .. 4) ), Nil, 'did we get no result';

# vim: ft=perl6 expandtab sw=4
