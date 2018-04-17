use v6.c;

use List::MoreUtils <onlyres only_result>;
use Test;

plan 5;

ok &onlyres =:= &only_result, 'is onlyres the same as only_result';

is onlyres( { 2 * $_ if $_ == 5 }, (4 .. 9) ), 10, "right only result";
is onlyres( { 2 * $_ if $_ > 5 }, (4 .. 9) ), Nil, "no right only result";
is onlyres( { $_ > 3 }, (1 .. 4) ), True, 'did we get boolean result';
is onlyres( { $_ > 5 }, (1 .. 4) ), Nil, 'did we get no result';

# vim: ft=perl6 expandtab sw=4
