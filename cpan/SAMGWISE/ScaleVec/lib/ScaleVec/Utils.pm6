use v6;

unit module ScaleVec::Utils;
use ScaleVec;
use JSON::Pretty;

sub sv(*@vector --> ScaleVec) is export {
  ScaleVec.new(:@vector)
}

sub save-sv(Str $file, ScaleVec $sv) is export {
  $file.IO.spurt: $sv.to-map.&to-json
}

sub load-sv(Str $file --> ScaleVec) is export {
  ScaleVec.from-map: $file.IO.slurp.&from-json
}
