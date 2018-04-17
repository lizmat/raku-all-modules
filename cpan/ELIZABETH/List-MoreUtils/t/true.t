use v6.c;

use List::MoreUtils <true>;
use Test;

plan 3;

my @list = 1 .. 10000;
is true( { .defined }, @list), 10000, 'are all values defined';
is true( { not .defined }, @list), 0, 'are no values undefined';
is true( { $_ < 2 }, @list), 1, 'are all but one value < 2';

# vim: ft=perl6 expandtab sw=4
