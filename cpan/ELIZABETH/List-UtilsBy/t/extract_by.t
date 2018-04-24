use v6.c;
use Test;
use List::UtilsBy <extract_by>;

plan 8;

# We'll need a real array to work on
my @numbers = 1 .. 10;

is-deeply extract_by( { 0 }, @numbers), [], 'extract false returns none';
is-deeply @numbers, [1 .. 10], 'extract false leaves array unchanged';

is-deeply extract_by( * %% 3, @numbers), [3,6,9], 'extract div3 returns values';
is-deeply @numbers, [1,2,4,5,7,8,10], 'extract div3 removes from array';

is-deeply extract_by( { $_[0] < 5 }, @numbers), [1,2,4 ],
  'extract $_[0] < 4 returns values';
is-deeply @numbers, [5,7,8,10], 'extract $_[0] < 4 removes from array';

is-deeply extract_by( { True }, @numbers), [5,7,8,10],
  'extract true returns all';
is-deeply @numbers, [], 'extract true leaves nothing';

# vim: ft=perl6 expandtab sw=4
