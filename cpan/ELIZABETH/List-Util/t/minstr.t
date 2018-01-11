use v6.c;

use List::Util <minstr>;
use Test;

plan 5;

my $v;

ok defined(&minstr), 'minstr defined';

$v = minstr('a');
is $v, 'a', 'single arg';

$v = minstr('a','b');
is $v, 'a', '2-arg ordered';

$v = minstr('B','A');
is $v, 'A', '2-arg reverse ordered';

my @a = "a" .. "z";
my @b = @a.pick(*);
$v = minstr(@b);
is $v, @a[0], 'random ordered';

# vim: ft=perl6 expandtab sw=4
