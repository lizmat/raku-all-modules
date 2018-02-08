#! /usr/bin/env perl6
use v6;
use Bench;
use ScaleVec;

my ScaleVec $octatonic-scale .= new: :vector( (0, 2, 3, 5, 6, 8, 9, 11, 12) );
my ScaleVec $triad .= new: :vector( (0, 2, 4) );
my ScaleVec $triad-rat .= new: :vector( (0.5, 2.5, 4.5) );

unit sub MAIN(Int :$iterations = 1000);
my Bench $b .= new;

say '-' x 78;
say '| ScaleVec |';
say "=== Int ===";
$b.timethese($iterations, {
  step              => sub { $octatonic-scale.step(12) },
  reflexive         => sub { $octatonic-scale.reflexive-step(12) },
  interval          => sub { $octatonic-scale.interval(12, 24) },
  map-onto          => sub { $triad.map-onto: $octatonic-scale },
});

say "=== Rat ===";
$b.timethese($iterations, {
  step              => sub { $octatonic-scale.step(12/5) },
  reflexive         => sub { $octatonic-scale.reflexive-step(12/5) },
  interval          => sub { $octatonic-scale.interval(12/5, 24/5) },
  map-onto          => sub { $triad-rat.map-onto: $octatonic-scale },
});
