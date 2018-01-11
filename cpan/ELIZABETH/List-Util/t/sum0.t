use v6.c;

use List::Util <sum0>;

use Test;
plan 9;

ok defined(&sum0), 'sum0 defined';

my $v is default(Nil) = sum0;
is $v, 0, 'no args';

$v = sum0(9);
is $v, 9, 'one arg';

$v = sum0(1,2,3,4);
is $v, 10, '4 args';

$v = sum0(-1);
is $v, -1, 'one -1';

my $x = -3;
$v = sum0($x, 3);
is $v, 0, 'variable arg';

$v = sum0(-3.5,3);
is $v, -0.5, 'real numbers';

$v = sum0(3,-3.5);
is $v, -0.5, 'initial integer, then real';

$v = sum0(
  933262154439441526816992388562667004907159682643,
  64381621468592963895217599993229915
);
is $v, 933262154439505908438460981526562222507152912558, 'bigints';

# vim: ft=perl6 expandtab sw=4
