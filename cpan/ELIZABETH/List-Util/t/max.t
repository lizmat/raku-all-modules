use v6.c;

use List::Util <max>;
use Test;

plan 5;

my $v is default(Nil);

ok defined(&max), 'max defined';

$v = max(1);
is $v, 1, 'single arg';

$v = max (1,2);
is $v, 2, '2-arg ordered';

$v = max(2,1);
is $v, 2, '2-arg reverse ordered';

my @a = map { rand }, 1 .. 20;
my @b = sort @a;
$v = max(@a);
is $v, @b[*-1], '20-arg random order';

# vim: ft=perl6 expandtab sw=4
