#! /usr/bin/env perl6
use v6;
use Test;

use-ok('ScaleVec::Scale::Intervalic');
use ScaleVec::Scale::Intervalic;
use ScaleVec;

my @major-interval-vector = 2, 2, 1, 2, 2, 2, 1;
my ScaleVec $major .= new(
  :vector(0, |@major-interval-vector.keys.map: -> $k {
    @major-interval-vector[0..$k].sum
  } )
);

ok so $major, "Instantiate ScaleVec::Scale object ok.";

is $major.repeat-interval, 12, "Is default repeat-interval 12 for major scale.";

for -7..14 -> $s {
  given $s {
    when 0 {
      is $major.step($s), 0, "Major step $s (for root of 0)";
    }
    when * < 0 {
      is $major.step($s), -@major-interval-vector[(@major-interval-vector.elems + $s) .. @major-interval-vector.end].sum, "Major step $s (for root of 0)";
    }
    when * > 7 {
      is $major.step($s), @major-interval-vector.sum + @major-interval-vector[0 .. ($s - 8)].sum, "Major step $s ({$s - 8}) (for root of 0)";
    }
    default {
      is $major.step($s), @major-interval-vector[0 .. ($s - 1)].sum, "Major step $s (for root of 0)";
    }
  }
}

is $major.step(14), 24, "Major step 15 (for root of 0)";
is $major.step(-8), -13, "Major step -8 (for root of 0)";
is $major.step(-1), -1, "Major step -1 (for root of 1)";
is $major.step(-14), -24, "Major step -14 (for root of 0)";

my ScaleVec $I .= new( :vector(0, 2, 4, 7) :ordered );
my ScaleVec $tonic = $I.map-onto: $major;

is $tonic.vector, (0, 4, 7), "Map chord onto scale.";

my ScaleVec $I-offset = $I.map-onto($major).transpose(60);
is $I-offset.scale-pv, (60, 64, 67, 72), "Map chord onto scale and transpose";

my ScaleVec $IV .= new( :vector(-4, -2, 0, 3) );
is $IV.map-onto($major).vector, (-7, -3, 0), "Map chord onto scale.";
is $IV.repeat-interval, $I.repeat-interval, "Identical IV chords repeat-interval is the same";

#test what should be a transperent mapping
my ScaleVec $transperent-scale .= new( :vector(0, 1) );

for -6..6 -> $n {
  is $I.step-to-pc($n), 0|1|2, "step-to-pc: $n (chord I)";
  is $transperent-scale.step-to-pc($n), 0|1, "step-to-pc: $n (transperent-scale)";
  is $transperent-scale.step-to-pc($n + $_), 0 + $_|1 + $_, "step-to-pc: { $n + $_} (transperent-scale)" given 1/3;
  is $transperent-scale.step-to-pc($n + $_), 0 + $_|1 + $_, "step-to-pc: { $n + $_} (transperent-scale)" given 1/2;
  is $transperent-scale.step-to-pc($n + $_), 0 + $_|1 + $_, "step-to-pc: { $n + $_} (transperent-scale)" given 2/3;

  is $I-offset.step-to-pc($_), 0|1|2, "step-to-pc: $_ (Chord I offset)" given $n + 60;
  is $IV.step-to-pc($_), 0|1|2, "step-to-pc: $_ (Chord IV)" given $n;
}
for -18..18 -> $n {
  is $major.step-to-pc($n), $major.scale-pv.keys.any, "step-to-pc: $n (major-scale)";
}

for -18..18 -> $n {
  is $major.step-to-octave($n), -3|-2|-1|0|1|2, "step-to-octave: $n (major scale)";
  is $I-offset.step-to-octave($_), (-6..6).List.any, "step-to-octave: $_ (Chord I offset)" given $n;
  is $IV.step-to-octave($_), (-6..6).List.any, "step-to-octave: $_ (Chord IV)" given $n;
}

for -6..6 -> $n {
  is $transperent-scale.step($n), $n, "step: $n (transperent-scale)";
  is $transperent-scale.step($_), $_, "step: $_ (transperent-scale)" given $n + 1/3;
  is $transperent-scale.step($_), $_, "step: $_ (transperent-scale)" given $n + 1/2;
  is $transperent-scale.step($_), $_, "step: $_ (transperent-scale)" given $n + 2/3;
}

#
# .interval(Int $a, Int $b) returns Numeric
#
for -6..6 -> $i {
  is $transperent-scale.interval($i, $i + 1/3), 1/3, "Transperent interval $i:{ $i + 1/3 }";
  is $transperent-scale.interval($i, $i + 1/2), 1/2, "Transperent interval $i:{ $i + 1/2 }";
  is $transperent-scale.interval($i, $i + 2/3), 2/3, "Transperent interval $i:{ $i + 2/3}";
  is $transperent-scale.interval($i, $i + 1), 1, "Transperent interval $i:{ $i + 1}";
}

is $major.interval(0, 2), 4, "interval 0 to 2 on major";

is $major.step(1.5), 3, "step 1.5 on major";

######## Reflexive methods ###################
for -6..6 -> $n {
  is $transperent-scale.value-to-pc($n), -1|0|1, "value-to-pc: $n";
}

for -18..18 -> $n {
  is $major.value-to-octave($n), -2|-1|0|1, "value-to-octave: $n";
  is $I-offset.value-to-octave($_), (-6..6).List.any, "value-to-octave: $_ (Chord I offset)" given $n + 60;
  is $IV.value-to-octave($_), (-6..6).List.any, "value-to-octave: $_ (Chord IV)" given $n - 5;
}
is $I-offset.value-to-octave($_), 0, "value-to-octave: $_ (Chord I offset)" given 60;
is $I-offset.value-to-octave($_), -1, "value-to-octave: $_ (Chord I offset)" given 59;

is $major.value-to-octave($_), 0, "value-to-octave: $_ (Major)" given 0;
is $major.value-to-octave($_), -1, "value-to-octave: $_ (Major)" given -1;
is $major.value-to-octave($_), 0, "value-to-octave: $_ (Major)" given 1;
is $major.value-to-octave($_), 0, "value-to-octave: $_ (Major)" given 11;
is $major.value-to-octave($_), 1, "value-to-octave: $_ (Major)" given 12;

is $IV.value-to-octave($_), 0, "value-to-octave: $_ (Chord IV)" given -4;
is $IV.value-to-octave($_), -1, "value-to-octave: $_ (Chord IV)" given -5;
is $IV.value-to-octave($_), 0, "value-to-octave: $_ (Chord IV)" given -3;
is $IV.value-to-octave($_), 0, "value-to-octave: $_ (Chord IV)" given 2;
is $IV.value-to-octave($_), 1, "value-to-octave: $_ (Chord IV)" given 3;

for -18..18 -> $n {
  is $major.value-to-whole-step($major.step: $n), 0|1|2|3|4|5|6, "value-to-whole-step: $n";
  is $I-offset.value-to-whole-step($_), 0|1|2, "value-to-whole-step: $_ (Chord I offset)" given $n + 60;
  is $IV.value-to-whole-step($_), 0|1|2, "value-to-whole-step: $_ (Chord I offset)" given $n - 5;
}
is $major.value-to-whole-step($major.step: -1), 6, "value-to-whole-step: -1";
is $major.value-to-whole-step($major.step: -2), 5, "value-to-whole-step: -2";
is $major.value-to-whole-step($major.step: -1.5), 5, "value-to-whole-step: -1.5";
is $major.value-to-whole-step($major.step: -2.5), 4, "value-to-whole-step: -2.5";

for -18..18 -> $n {
  is $major.value-to-sub-step($major.step: $n + 1/3), 1/3, "value-to-sub-step: { $n + 1/3 }";
  is $major.value-to-sub-step($major.step: $n + 0.5), 0.5, "value-to-sub-step: { $n + 0.5 }";
  is $major.value-to-sub-step($major.step: $n + 2/3), 2/3, "value-to-sub-step: { $n + 2/3 }";
  is $I-offset.value-to-sub-step($I-offset.step($_), :diag), 1/3, "value-to-sub-step: $_ (Chord I offset)" given $n + 1/3;
  is $I-offset.value-to-sub-step($I-offset.step($_), :diag), 1/2, "value-to-sub-step: $_ (Chord I offset)" given $n + 1/2;
  is $I-offset.value-to-sub-step($I-offset.step($_), :diag), 2/3, "value-to-sub-step: $_ (Chord I offset)" given $n + 2/3;
}

for -18..18 -> $n {
  is $major.octave-to-step($major.value-to-octave: $n), -14|-7|0|7, "octave-to-step: $n";
  is $IV.octave-to-step($IV.value-to-octave: $n), -6|-3|0|3|6|9, "octave-to-step: $n (Chord IV)";
}
is $IV.octave-to-step($IV.value-to-octave: $_), 0, "octave-to-step: $_" given 0;
is $IV.octave-to-step($IV.value-to-octave: $_), 0, "octave-to-step: $_" given 1;
is $IV.octave-to-step($IV.value-to-octave: $_), 6, "octave-to-step: $_" given 10;
is $IV.octave-to-step($IV.value-to-octave: $_), 6, "octave-to-step: $_" given 12;
is $IV.octave-to-step($IV.value-to-octave: $_), 3, "octave-to-step: $_" given 8;

is $IV.reflexive-step(10), 6, "Chord IV correct octave";
is $IV.reflexive-step(12), 7, "Chord IV correct octave";


#
# .reflexive-step
#
for -12..12 -> $i {
  is $transperent-scale.reflexive-step($i), $i, "transperent.reflexive-step($i)";
}

for (-24..24).map: * × ½ -> $i {
  is $transperent-scale.reflexive-step($i), $i, "transperent.reflexive-step($i)";
}

is $major.reflexive-step(-9), -5.5, "major.reflexive-step(-9)";
is $major.reflexive-step(-2), -1.5, "major.reflexive-step(-2)";
is $major.reflexive-step(1), 0.5,   "major.reflexive-step(1)";
is $major.reflexive-step(2), 1,     "major.reflexive-step(2)";
is $major.reflexive-step(6), 3.5,   "major.reflexive-step(6)";
is $major.reflexive-step(7), 4,     "major.reflexive-step(7)";
is $major.reflexive-step(12), 7,    "major.reflexive-step(12)";
is $major.reflexive-step(13), 7.5,  "major.reflexive-step(13)";

#
# Refelxivity testing
#
my ScaleVec $micro .= new( :vector(0, 0.5) );
my ScaleVec $pos-offset .= new( :vector(60, 61) );
my ScaleVec $neg-offset .= new( :vector(-60, -61) );
my ScaleVec $neg-major = $major.transpose(-12);
is $neg-major.root, -12, "Major(-12) == -12";
for -18..18 -> $n {
  for (0, 1/3, 1/2, 2/3).map( * + $n ) -> $v {
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Transperent)" given $transperent-scale;
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Micro)" given $micro;
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Negative offset)" given $neg-offset;
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Positive offset)" given $pos-offset;
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Chord I)" given $I;
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Chord I offset)" given $I-offset;
    is .reflexive-step( .step( .reflexive-step($v) ) ), .reflexive-step($v), "Reflexive step round trip for $v (Major)" given $major;
    is(
      $IV.reflexive-step($neg-major.reflexive-step( $neg-major.step: $IV.step( $IV.reflexive-step($neg-major.reflexive-step: $v) ) )),
      $IV.reflexive-step($neg-major.reflexive-step: $v),
      "Chained reflexive step round trip for $v (Major(-12) & Chord IV)"
    );
  }
}

done-testing;
