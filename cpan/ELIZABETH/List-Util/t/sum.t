use v6.c;

use List::Util <sum>;

use Test;
plan 9;

ok defined(&sum), 'sum defined';

my $v is default(Nil) = sum;
is $v, Nil, 'no args';

$v = sum(9);
is $v, 9, 'one arg';

$v = sum(1,2,3,4);
is $v, 10, '4 args';

$v = sum(-1);
is $v, -1, 'one -1';

my $x = -3;
$v = sum($x, 3);
is $v, 0, 'variable arg';

$v = sum(-3.5,3);
is $v, -0.5, 'real numbers';

$v = sum(3,-3.5);
is $v, -0.5, 'initial integer, then real';

$v = sum(
  933262154439441526816992388562667004907159682643,
  64381621468592963895217599993229915
);
is $v, 933262154439505908438460981526562222507152912558, 'bigints';

# vim: ft=perl6 expandtab sw=4
