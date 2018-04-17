use v6.c;

use List::MoreUtils <all_u>;
use Test;

plan 4;

my @list = 1 .. 10000;
is all_u( *.defined, @list), True, 'all elements defined';
is all_u( * > 0, @list), True, 'all elements larger than 0';
is all_u( * < 5000, @list), False, 'not all elements smaller than 5000';
is all_u( { False }, []), Nil, 'empty list returns True always';

# vim: ft=perl6 expandtab sw=4
