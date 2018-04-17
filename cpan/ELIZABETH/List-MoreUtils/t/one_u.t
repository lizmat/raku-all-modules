use v6.c;

use List::MoreUtils <one_u>;
use Test;

plan 6;

my @list = 1 .. 300;
is one_u( * == 1, @list), True, 'Only one 1';
is one_u( * == 150, @list), True, 'Only one 150';
is one_u( * == 300, @list), True, 'Only one 300';
is one_u( * == 0, @list), False, '0 did not occur once';
is one_u( * > 1, @list), False, 'greater than 1 occurred more than once';
is one_u( { False }, []), Nil, 'empty list returns Nil always';

# vim: ft=perl6 expandtab sw=4
