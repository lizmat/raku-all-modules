use v6.c;

use List::MoreUtils <one>;
use Test;

plan 6;

my @list = 1 .. 300;
is one( * == 1, @list), True, 'Only one 1';
is one( * == 150, @list), True, 'Only one 150';
is one( * == 300, @list), True, 'Only one 300';
is one( * == 0, @list), False, '0 did not occur once';
is one( * > 1, @list), False, 'greater than 1 occurred more than once';
is one( { False }, []), False, 'empty list returns False always';

# vim: ft=perl6 expandtab sw=4
