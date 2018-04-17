use v6.c;

use List::MoreUtils <lastval last_value>;
use Test;

plan 3;

ok &lastval =:= &last_value, 'is lastval the same as last_value';

is lastval( { $_ > 5 }, (4 .. 9) ), 9, "right last result";
is lastval( { $_ > 5 }, (1 .. 4) ), Nil, 'did we get no result';

# vim: ft=perl6 expandtab sw=4
