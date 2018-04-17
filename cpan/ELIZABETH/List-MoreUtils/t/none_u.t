use v6.c;

use List::MoreUtils <none_u>;
use Test;

plan 4;

my @list = 1 .. 10000;
is none_u( !*.defined, @list), True, 'no undefined elements';
is none_u( * > 10000, @list), True, 'no elements larger than 10000';
is none_u( * < 5000, @list), False, 'some elements smaller than 5000';
is none_u( { False }, []), Nil, 'empty list returns Nil always';

# vim: ft=perl6 expandtab sw=4
