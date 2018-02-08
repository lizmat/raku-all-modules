use v6;

use ScaleVec::Scale;
unit class ScaleVec::Scale::Stack does ScaleVec::Scale;

has ScaleVec::Scale @.scales;

method step(Numeric $s) returns Numeric {
  reduce { $^b.step($^a) }, $s, |@!scales;
}
