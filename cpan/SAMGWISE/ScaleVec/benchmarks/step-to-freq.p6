#! /usr/bin/env perl6
use v6;
use Bench;
use ScaleVec;
use ScaleVec::Scale::EqualTemperment;

my ScaleVec::Scale::EqualTemperment $scale .= new;
my ScaleVec $triad .= new: :vector( (0, 2, 4) );
my ScaleVec $triad-rat .= new: :vector( (0.5, 2.5, 4.5) );

unit sub MAIN(Int :$iterations = 1000);
my Bench $b .= new;

say '-' x 78;
say '| ScaleVec::Scale::EqualTemperment |';
say "=== Int ===";
$b.timethese($iterations, {
  step              => sub { $scale.step(12) },
  interval          => sub { $scale.interval(12, 24) },
  map-onto          => sub { $triad.map-onto: $scale },
});

say "=== Rat ===";
$b.timethese($iterations, {
  step              => sub { $scale.step(12/5) },
  interval          => sub { $scale.interval(12/5, 24/5) },
  map-onto          => sub { $triad-rat.map-onto: $scale },
});
