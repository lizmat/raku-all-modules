
use v6;
use Test;
use Duo;
use Duo::Util;

my \p1 = duo(1, 2);
my \p2 = 1 → 2;

ok p1, 'can create pair with sub';
ok p2, 'can create pair with syntax';

isa-ok p1, Duo;
isa-ok p2, Duo;

is ~p1, '1 => 2';
is ~p2, '1 => 2';

done-testing;

# vim: ft=perl6
