use v6.c;

use List::Util <min>;
use Test;

plan 5;

my $v is default(Nil);

ok defined(&min), 'min defined';

$v = min(1);
is $v, 1, 'single arg';

$v = min (1,2);
is $v, 1, '2-arg ordered';

$v = min(2,1);
is $v, 1, '2-arg reverse ordered';

my @a = map { rand }, 1 .. 20;
my @b = sort @a;
$v = min(@a);
is $v, @b[0], '20-arg random order';

# vim: ft=perl6 expandtab sw=4
