use lib 'lib';
use Bench;
use Test;

plan 1;

if (try require ::('Telemetry') <&infix:<->>) !~~ Nil {
  my $b = Bench.new;
  ok (4.5*1000000) < $b.timethis(1, sub { sleep 5; })[0].wallclock < (5.5*1000000), 'Timing test';
} else {
  skip-rest;
}

done-testing;
