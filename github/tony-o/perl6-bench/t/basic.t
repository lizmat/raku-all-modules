
use lib 'lib';
use Bench;
use Test;

plan 1;

my $b = Bench.new;

ok 4.5 < $b.timethis(1, sub { sleep 5; })[0] < 5.5, 'Timing test';

done-testing;
