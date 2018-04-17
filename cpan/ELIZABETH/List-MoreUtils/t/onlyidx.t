use v6.c;

use List::MoreUtils <onlyidx only_index>;
use Test;

plan 6;

ok &onlyidx =:= &only_index, 'is onlyidx the same as only_index';

my @list = 1 .. 10000;

is onlyidx( { $_ == 5000 }, @list), 4999,  "onlyidx";
is onlyidx( { $_ >= 5000 }, @list), -1,  "onlyidx";
is onlyidx( { not .defined }, @list), -1, "invalid onlyidx";
is onlyidx( { .defined }, @list), -1, "real onlyidx";
is onlyidx( { True }, ()), -1, "empty onlyidx";

# vim: ft=perl6 expandtab sw=4
