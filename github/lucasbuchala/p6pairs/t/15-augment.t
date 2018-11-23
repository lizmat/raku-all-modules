
use v6;
use Test;
use Duo;
use Duo::Augment;

is-deeply Pair.Duo, Duo, 'type Pair.Duo';

my \p = 1 => 2;
my \d = Duo.new(1, 2);

is-deeply p.Duo, d, 'instance pair.Duo';

done-testing;

# vim: ft=perl6
