use v6.c;
use Test;

use Array::Circular;

plan 5;

my @a is circular(3);

my $a = 42;
@a.push($a++) for ^4;
is @a, "43 44 45", '4 time push';

is @a.pop, 45, '1x pop';
is @a, "43 44", 'after 1x pop';
@a.push(666);
is @a, "43 44 666", '1 time push';

@a.unshift(666);
is @a, "666 43 44", '1 time unshift';

# vim: ft=perl6 expandtab sw=4
