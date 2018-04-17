use v6.c;

use List::MoreUtils <any>;
use Test;

plan 6;

my @list = 1 .. 10000;
is any( * == 5000, @list), True, 'at least 1 element 5000';
is any( * == 5000, (1..10000)), True, 'at least 1 element 5000';
is any( *.defined, @list), True, 'at least one element defined';
is any( !*.defined, @list), False, 'no elements not defined';
is any( !*.defined, (Int,)), True, 'at least one element not defined';
is any( { True }, []), False, 'empty list returns False always';

# vim: ft=perl6 expandtab sw=4
