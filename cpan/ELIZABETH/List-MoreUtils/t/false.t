use v6.c;

use List::MoreUtils <false>;
use Test;

plan 3;

my @list = 1 .. 10000;
is false( { not .defined }, @list), 10000, 'are all values defined';
is false( { .defined }, @list), 0, 'are no values undefined';
is false( { $_ > 1 }, @list), 1, 'are all but one value > 1';

# vim: ft=perl6 expandtab sw=4
