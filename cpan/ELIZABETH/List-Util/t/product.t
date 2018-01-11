use v6.c;

use List::Util <product>;

use Test;
plan 12;

ok defined(&product), 'product defined';

my $v = product;
is $v, 1, 'no args';

$v = product(9);
is $v, 9, 'one arg';

$v = product(1,2,3,4);
is $v, 24, '4 args';

$v = product(-1);
is $v, -1, 'one -1';

$v = product(0, 1, 2);
is $v, 0, 'first factor zero';

$v = product(0, 1);
is $v, 0, '0 * 1';

$v = product(1, 0);
is $v, 0, '1 * 0';

$v = product(0, 0);
is $v, 0, 'two 0';

my $x = -3;
$v = product($x, 3);
is $v, -9, 'variable arg';

$v = product(-3.5,3);
is $v, -10.5, 'real numbers';

$v = product(1..99);
is $v, 933262154439441526816992388562667004907159682643816214685929638952175999932299156089414639761565182862536979208272237582511852109168640000000000000000000000, 'big ints';

# vim: ft=perl6 expandtab sw=4
