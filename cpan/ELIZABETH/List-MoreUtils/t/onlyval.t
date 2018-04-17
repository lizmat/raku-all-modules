use v6.c;

use List::MoreUtils <onlyval only_value>;
use Test;

plan 3;

ok &onlyval =:= &only_value, 'is onlyval the same as only_value';

is onlyval( { $_ == 5 }, (4 .. 9) ), 5, "right only result";
is onlyval( { $_ > 5 }, (4 .. 9) ), Nil, "no right only result";

# vim: ft=perl6 expandtab sw=4
