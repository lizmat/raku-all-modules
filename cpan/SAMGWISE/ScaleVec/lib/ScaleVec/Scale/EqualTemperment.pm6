use v6;
use ScaleVec::Scale;

unit role ScaleVec::Scale::EqualTemperment does ScaleVec::Scale;

has $.tones-per-octave = 12;
has $.ref-freq         = 440; #Hz
has $.ref-step         = 49;

method step(Numeric $step) returns Numeric {
  $!ref-freq * self.root-of-two ** ($step - $!ref-step)
}

method root-of-two() {
  2 ** (1 / $!tones-per-octave)
}
