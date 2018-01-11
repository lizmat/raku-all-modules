use v6.c;

use List::Util <maxstr>;
use Test;

plan 5;

my $v is default(Nil);

ok defined(&maxstr), 'maxstr defined';

$v = maxstr('a');
is $v, 'a', 'single arg';

$v = maxstr('a','b');
is $v, 'b', '2-arg ordered';

$v = maxstr('B','A');
is $v, 'B', '2-arg reverse ordered';

my @a = "a" .. "z";
my @b = @a.pick(*);
$v = maxstr(@b);
is $v, @a[*-1], 'random ordered';

# vim: ft=perl6 expandtab sw=4
