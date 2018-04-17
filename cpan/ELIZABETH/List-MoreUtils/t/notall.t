use v6.c;

use List::MoreUtils <notall>;
use Test;

plan 4;

my @list = 1 .. 10000;
is notall( !*.defined, @list), True, 'all elements defined';
is notall( * < 10000, @list), True, 'not all elements smaller than 10000';
is notall( * < 50000, @list), False, 'all elements smaller than 50000';
is notall( { False }, []), False, 'empty list returns False always';

# vim: ft=perl6 expandtab sw=4
