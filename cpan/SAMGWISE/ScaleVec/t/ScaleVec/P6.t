#! /usr/bin/env perl6
use v6;
use Test;

use-ok 'ScaleVec';
use ScaleVec;

my $vector = (60, 64, 67);

my ScaleVec $chord .= new( :$vector :repeat-interval(12));
ok so $chord, "Instantiate ScaleVec object";

is $chord.vector.values, $vector, "Pitch vector out matches pitch vector in";

is $chord.intervals, (4, 7), "Relative intervals for major triad";

is $chord.interval-vector, (4, 3), "interval-vector for major triad";

for 0..2 -> $s {
  is $chord.step($s), $vector[$s], "step $s == \$vector[$s]";
}

is $chord.root, $vector[0], "root";

is $chord.ordered.vector, $chord.vector, "is chord set pitch vector matching";

is $chord.map-between($chord.ordered),  (0 => 0, 1 => 1, 2 => 2),     "Generate map between vector to set";
is $chord.map-between-self,               $chord.map-between($chord.ordered), "Generate map between vector to set of self";

#
# Inversions
#

#Test positive inversions
is $chord.inversion(0).vector,  $vector,
  "inversion 0 => { $chord.inversion(0).vector.perl },  { $vector.perl }.";

is $chord.inversion(1).vector,  (|$vector[1, 2], $vector[0] + 12),
  "inversion 1 => { $chord.inversion(1).vector.perl },  { (|$vector[1, 2], $vector[0] + 12).perl }.";

is $chord.inversion(2).vector,  ($vector[2], |$vector[0, 1].map( * + 12 )),
  "inversion 2 => { $chord.inversion(2).vector.perl },   { ($vector[2], |$vector[0, 1].map( * + 12 )).perl }.";

is $chord.inversion(3).vector,  $vector.map( * + 12 ),
  "inversion 3 => { $chord.inversion(3).vector.perl },  { |$vector.map( * + 12 ).perl }.";

#Test Negative transpositions
is $chord.inversion(-1).vector,  ($vector[2] - 12, |$vector[0, 1]),
  "inversion -1 => { $chord.inversion(-1).vector.perl },  { ($vector[2] - 12, |$vector[0, 1]).perl }.";

is $chord.inversion(-2).vector,  (|$vector[1, 2].map(* - 12), |$vector[0]),
  "inversion -2 => { $chord.inversion(-2).vector.perl },  { (|$vector[1, 2].map(* - 12), |$vector[0]).perl }.";

is $chord.inversion(-3).vector,  $vector.map(* - 12),
  "inversion -3 => { $chord.inversion(-3).vector.perl },  { $vector.map(* - 12).perl }.";

is $chord.retrograde.vector, $vector.reverse, "Chord retrograde";
is $chord.iv-retrograde.vector, (60, 63, 67), "Chord intervalic retrograde";

is $chord.diminish(1).vector,   $vector.map( * - 1),        "Chord diminish(1)";
is $chord.diminish(1/2).vector, $vector.map( * / 2),        "Chord diminish(1/2)";

is $chord.augment(1).vector,    $vector.map( * + 1),        "Chord augment(1)";
is $chord.augment(1/2).vector,  $vector.map( {$_ * 1.5} ),  "Chord augment(1)";

is $chord.voice-leading-permutations($chord.augment(1)), ((1, 5, 8), (-3, 1, 4), (-6, -2, 1)), "voice-leading-permutations on augment 1";

is $chord.interval-vector-diff($chord).sum,           0,          "interval-vector-diff sums to 0 for same chord";
is $chord.interval-vector-diff($chord.augment(1)),    (0, 0),     "interval-vector-diff on augment 1 is (0, 0) - no difference";
is $chord.interval-vector-diff($chord.augment(1/2)),  (2, 1.5),   "interval-vector-diff on augment 1/2 is (2, 1.5)";
is $chord.interval-vector-diff($chord.diminish(1/2)), (-2, -1.5), "interval-vector-diff on diminish 1/2 is (-2, -1.5)";

is $chord.mirror-inversion.vector, (-60, -64, -67), "mirror-inversion";

is $chord.transpose(-60).vector, (0, 4, 7), "transpose";

is $chord.distance($chord),             0,                                      "0 distance to self";
is $chord.distance($chord.augment: 1),  (1, 1, 1).map( {$_ ** 2} ).sum.sqrt,    "distance between self and augment(1)";
is $chord.distance($chord.diminish: 1), (-1, -1, -1).map( {$_ ** 2} ).sum.sqrt, "distance between self and diminish(1)";

for -4..4 -> $i {
  is $chord.cycle($i), $chord.vector[$i mod $chord.vector.elems], "cycle $i";
}

done-testing;
