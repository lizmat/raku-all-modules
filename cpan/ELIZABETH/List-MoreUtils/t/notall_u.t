use v6.c;

use List::MoreUtils <notall_u>;
use Test;

plan 4;

my @list = 1 .. 10000;
is notall_u( !*.defined, @list), True, 'all elements defined';
is notall_u( * < 10000, @list), True, 'not all elements smaller than 10000';
is notall_u( * < 50000, @list), False, 'all elements smaller than 50000';
is notall_u( { False }, []), Nil, 'empty list returns Nil always';

# vim: ft=perl6 expandtab sw=4
