use Test;

use lib 'lib';

use List::Combinations;

my @a = ^10;

my @b = combos(@a, 0);
ok (@b ~~ (), 'empty list for 0-combinations');

my @c = combos(@a, 1);
ok (@c ~~ @a, 'same list for 1-combinations');

my @d = @a.combinations(2).sort;
my @e = combos(@a, 2).sort;
ok (@d ~~ @e, 'combos() and combinations() are the same');

my @f = combos(10, 2).sort;
ok (@f ~~ @e, 'range version is the same');

done-testing;
