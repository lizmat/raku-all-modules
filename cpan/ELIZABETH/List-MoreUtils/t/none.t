use v6.c;

use List::MoreUtils <none>;
use Test;

plan 4;

my @list = 1 .. 10000;
is none( !*.defined, @list), True, 'no undefined elements';
is none( * > 10000, @list), True, 'no elements larger than 10000';
is none( * < 5000, @list), False, 'some elements smaller than 5000';
is none( { False }, []), True, 'empty list returns True always';

# vim: ft=perl6 expandtab sw=4
