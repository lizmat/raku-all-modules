use v6;

unit role ScaleVec::Vectorable;

method root()             returns Numeric { ... }

method repeat-interval()  returns Numeric { ... }

method vector()           returns Seq     { ... }

method interval-vector()  returns Seq     { ... }

method intervals()        returns Seq     { ... }

sub pv-to-iv(Positional $vector) is export returns Seq {
  gather for ^$vector.end -> $i {
    take $vector[$i + 1] - $vector[$i];
  }
}

sub iv-to-pv(Positional $interval-vector, Numeric :$root = 0) is export returns Seq {
  return Seq unless $interval-vector.elems > 1;
  my $previous-pitch = $root;
  gather for 0, |$interval-vector[] -> $interval {
    take $previous-pitch += $interval;
  }
}
