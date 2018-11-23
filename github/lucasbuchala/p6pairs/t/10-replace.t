
use v6;
use Test;
use Duo;

my \d1 = Duo.new(0, 0);
my \d2 = Duo.new(1, 2);
my \cd = Duo.new(1e0, 2e0);

is-deeply d1.replace(d2),    d2, 'replace(Duo)';
is-deeply d1.replace(1=>2),  d2, 'replace(Pair)';
is-deeply d1.replace([1,2]), d2, 'replace(Array)';
is-deeply d1.replace((1,2)), d2, 'replace(List)';
is-deeply d1.replace(1..2),  d2, 'replace(Range)';
is-deeply d1.replace(1/2),   d2, 'replace(Rat)';
is-deeply d1.replace(1+2i),  cd, 'replace(Complex)';

is-deeply d1.replace((1,2).Slip), d2, 'replace(Slip)';

# is-deeply d1.replace({1=>2}), d2, 'replace(Hash)';

# p.set((1, 2).Slip);

done-testing;

# vim: ft=perl6
