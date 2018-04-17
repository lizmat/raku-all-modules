use v6.c;

use List::MoreUtils <equal_range>;
use Test;

plan 5;

my @list = 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6, 7, 7, 7,
           8, 8, 9, 9, 9, 9, 9, 11, 13, 13, 13, 17;
is-deeply equal_range( { $_ <=> 0 }, @list), (0,0),   "equal range 0";
is-deeply equal_range( { $_ <=> 1 }, @list), (0,2),   "equal range 1";
is-deeply equal_range( { $_ <=> 2 }, @list), (2,4),   "equal range 2";
is-deeply equal_range( { $_ <=> 4 }, @list), (10,14), "equal range 4";
is-deeply equal_range( { $_ <=> 19 }, @list), (+@list,+@list), "equal range 19";

# vim: ft=perl6 expandtab sw=4
