use v6;

unit role ScaleVec::Scale;

method step(Numeric $step) returns Numeric { ... }

method interval(Numeric $a, Numeric $b) returns Numeric
#= Returns the exterior interval of the intervalic space between A and B.
{
  self.step($b) - self.step($a);
}
