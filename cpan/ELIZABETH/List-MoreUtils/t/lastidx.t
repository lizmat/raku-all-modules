use v6.c;

use List::MoreUtils <lastidx last_index>;
use Test;

plan 5;

ok &lastidx =:= &last_index, 'is lastidx the same as last_index';

my @list = 1 .. 10000;

is lastidx( { $_ >= 5000 }, @list), 9999,  "lastidx";
is lastidx( { not .defined }, @list), -1, "invalid lastidx";
is lastidx( { .defined }, @list), 9999, "real lastidx";
is lastidx( { True }, ()), -1, "empty lastidx";

# vim: ft=perl6 expandtab sw=4
