use v6.c;

use List::MoreUtils <each_array each_arrayref>;
use Test;

plan 11;

my @a  = 7, 3, 'a', Any, 'r';
my @b  = <a 2 -1 x>;
my &it = each_array @a, @b;
my @r;
my @idx;

while it() -> ($a,$b) {
    @r.push($a, $b);
    @idx.push( it('index') );
}

is-deeply it(), (), 'does exhausted iterator return () still';

is-deeply @r, [7, 'a', 3, <2>, 'a', <-1>, Any, 'x', 'r', Any],
  'did we get the right values?';
is-deeply @idx, [0 .. 4],
  'did we get the right indexes';

# Testing two iterators on the same arrays in parallel
@a = 1, 3, 5;
@b = 2, 4, 6;
my &i1 = each_array @a, @b;
my &i2 = each_array @a, @b;
@r = ();

while (my @r1 = i1()) and (my @r2 = i2()) {
    @r.push(|@r1,|@r2);
}
is-deeply @r, [1, 2, 1, 2, 3, 4, 3, 4, 5, 6, 5, 6],
  "did we get right values of 2 iterators on the same array";

# Input arrays must not be modified
is-deeply @a, [1, 3, 5], 'is @a unchanged';
is-deeply @b, [2, 4, 6], 'is @b unchanged';

my &ea = each_arrayref ([1 .. 26], ['A' .. 'Z']);
@a = @b = ();

while ea() -> ($a,$b) {
    @a.push($a);
    @b.push($b);
}
is-deeply @a, [1 .. 26], "got numbers from each_arrayref";
is-deeply @b, ['A' .. 'Z'], "got strings from each_arrayref";

# And this even used to dump core
my @nums = 1 .. 26;
&ea = each_arrayref (@nums, ['A' .. 'Z']);
@a = @b = ();

while ea() -> ($a,$b) {
    @a.push($a);
    @b.push($b);
}
is-deeply @a, [1 .. 26], "got numbers from each_arrayref";
is-deeply @a, @nums, "got array from each_arrayref";
is-deeply @b, ['A' .. 'Z'], "got strings from each_arrayref";

# vim: ft=perl6 expandtab sw=4
