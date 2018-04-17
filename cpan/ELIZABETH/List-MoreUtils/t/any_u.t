use v6.c;

use List::MoreUtils <any_u>;
use Test;

plan 6;

my @list = 1 .. 10000;
is any_u( * == 5000, @list), True, 'at least 1 element 5000';
is any_u( * == 5000, (1..10000)), True, 'at least 1 element 5000';
is any_u( *.defined, @list), True, 'at least one element defined';
is any_u( !*.defined, @list), False, 'no elements not defined';
is any_u( !*.defined, (Int,)), True, 'at least one element not defined';
is any_u( { True }, []), Nil, 'empty list returns Nil always';

# vim: ft=perl6 expandtab sw=4
