use v6;
use ScaleVec::Vectorable;
use ScaleVec::Scale;

unit role ScaleVec::Scale::Intervalic does ScaleVec::Scale does ScaleVec::Vectorable;

method scale-pv( --> Seq) {
  gather {
    for self.vector -> $elem {
      take $elem
    }
    take self.root + self.repeat-interval
  }
}

method scale-iv( --> Seq) {
  pv-to-iv self.scale-pv
}

method step-to-pc(Numeric $step --> Numeric) {
  # Remove any offset from zero caused by the root value.
  # This ensures a correct pitch class result
  ($step - self.scale-pv.end) % self.scale-pv.end
}

method step-to-octave(Numeric $step --> Numeric) {
  ( ($step - self.step-to-pc($step)) / self.scale-pv.end )
}

method step(Numeric $step --> Numeric) {
  my $pc = self.step-to-pc($step);
  my Int $pc-floor = $pc.floor;
  self.root + (self.step-to-octave($step) * self.repeat-interval)   # octave
  + self.value-to-pc(self.scale-pv[$pc-floor])                      # pc.floor -> value
  + ( ($pc - $pc-floor) * self.scale-iv[$pc-floor] )                # 0.* -> value
}

# method alt-step(Numeric $step) returns Numeric {
#   if $step == 0 {
#     return self.root;
#   }
#   elsif $step ~~ Int {
#     my $interval-count = self.scale-pv.end;
#     return self.root
#       + self.scale-iv.head( 1 + (($step - 1) mod $interval-count) ).sum
#       + ( (($step - 1) div $interval-count) * self.repeat-interval )
#   }
#   else {
#     my $step-int = $step.truncate;
#     my $step-int-val = self.step($step-int);
#     return $step-int-val
#       + ( (self.step($step-int + 1) - $step-int-val) * ($step - $step-int) )
#   }
# }

method value-to-pc(Numeric $value --> Numeric) {
  (($value - self.root) % self.repeat-interval)
}

method value-to-octave(Numeric $value --> Numeric) {
  ( ($value - self.value-to-pc($value)) / self.repeat-interval )
  - ( self.root / self.repeat-interval )
}

method value-to-whole-step(Numeric $value --> Numeric) {
  my $pc = self.value-to-pc($value);
  for self.scale-pv.kv -> $step, $val {
    if self.value-to-pc($val) <= $pc and $pc < self.value-to-pc(self.step($step + 1)) {
      return $step
    }
  }
  self.scale-pv.end - 1
}

method value-to-sub-step(Numeric $value, Bool :$diag--> Numeric) {
  my $whole-step = self.value-to-whole-step($value);
  ( self.value-to-pc($value) - self.value-to-pc(self.step: $whole-step) )
    / self.interval($whole-step, $whole-step + 1);
  # my $pc = self.value-to-pc($value);
  # my $pc-whole-step = self.value-to-pc(self.step($whole-step));
  # my $remaining-interval = ($pc - $pc-whole-step);
  # my $whole-interval = self.interval($whole-step, $whole-step + 1);
  # my $result = ( $remaining-interval / $whole-interval );
  # $*ERR.say(qq:to/DIAG/) if $diag;
  #   $value -> { $remaining-interval }<$pc - $pc-whole-step\<$whole-step -> {self.scale-pv[$whole-step]}>> / { $whole-interval } = $result
  #   DIAG
  # $result
}

method octave-to-step(Int(Cool) $octave --> Numeric) {
  $octave * self.scale-pv.end
}

method reflexive-step(Numeric $step-value --> Numeric) {
  temp $_ = self;
  .octave-to-step(.value-to-octave($step-value))
    + .value-to-whole-step($step-value)
    + .value-to-sub-step($step-value)

  # my Numeric $nibble = $step-value - $step-value.floor;
  # my Int $int-step = Int($step-value - $nibble);
  # my Numeric $pc-value = $step-value % self.repeat-interval;
  # my ($step-below, $value-below) = ( self.scale-pv.kv.map( -> $k, $v { $($k, $v) } ).grep( { .[1] <= $pc-value } ) ).tail;
  # ( ($int-step div self.repeat-interval) * self.scale-pv.end )  # Octave steps
  # + ( $step-below )                                             # closest whole step below the value's PC
  # + ( $pc-value - $value-below) / 1                             # The ratio of the remaining value to the next step

  # my $normalised-value = $step-value - self.root;
  # my $pv-count = self.scale-pv.end;
  # my $divisor = self.repeat-interval;
  # my $step-franction = $normalised-value / $divisor;
  # my $remainder = $step-franction - $step-franction.floor;
  # my $value-pc = $normalised-value % self.repeat-interval;
  # for self.scale-pv.kv -> $n, $element {
  #   if $value-pc >= $element {
  #     #my $previous-step-ratio = self.interval($n - 1, $n) / $divisor;
  #     #my $micro-step-remainder = ($remainder * $divisor) - self.step($n - 1);
  #     return ( $pv-count * ( ($normalised-value - $value-pc) / self.repeat-interval ) ) #octaves
  #       + ($n - 1)                                              #whole steps
  #       + ( ($value-pc - self.step($n - 1)) / (($normalised-value > 0) ?? 1 !! -1) )
  #       #+ (( ($remainder * $divisor) - self.step($n - 1) ) / self.interval($n - 1, $n))   #partial step
  #   }
  # }

  #When * is greater than largest element but less than repeat interval
  # return ($pv-count * ($step-franction - $remainder)) #octaves
  #     + ($pv-count - 1)                               #whole steps
  #     + ( #partial step:
  #       ($remainder * $divisor)
  #       - self.step($pv-count - 1)
  #       / self.interval($pv-count - 1, $pv-count)
  #     );
}
