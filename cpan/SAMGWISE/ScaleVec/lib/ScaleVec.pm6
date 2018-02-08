use v6.c;
use ScaleVec::Vector;
use Serialise::Map;

unit class ScaleVec:ver<0.0.3> does ScaleVec::Vector does Serialise::Map;
use ScaleVec::Scale;
use ScaleVec::Vectorable;

=begin pod

=head1 NAME

ScaleVec - A flexible yet accurate music representation system.

=head1 SYNOPSIS

  use ScaleVec;

  my ScaleVec $major-scale .= new( :vector(0, 2, 4, 5, 7, 9, 11, 12) );

  # Midi notes 0 - 127 with our origin on middle C (for most midi specs)
  use ScaleVec::Scale::Fence;
  my ScaleVec::Scale::Fence $midi .= new(
    :vector(60, 61)
    :repeat-interval(12)
    :lower-limit(0)
    :upper-limit(127)
  );

  # A two octave C major scale in midi note values
  say do for -7..7 {
    $midi.step: $major-scale.step($_)
  }

=head1 DESCRIPTION

Encapsulating the power of linear algebra in an easy to use music library, ScaleVec provides a way to represent musical structures such as chords, rhythms, scales and tempos with a common format.

=head1 CONTRIBUTIONS

To contribute, head to the github page: https://github.com/samgwise/p6-ScaleVec

=head1 AUTHOR

 Sam Gillespie

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

has Numeric @!vector;
has Numeric @!interval-vector;
has Numeric $!repeat-interval;
has Bool    $!ordered;
has Numeric %!step-cache;
has Numeric %!reflexive-cache;

submethod BUILD(Positional :$vector, Bool :$ordered, Numeric :$repeat-interval) {
  my @values = ($ordered ?? $vector.unique.sort !! $vector);
  $!repeat-interval = $repeat-interval.defined ?? $repeat-interval !! (
    @values.pop - @values.head
  );

  for @values -> $v {
    @!vector.push: $v.Numeric
  }

  @!interval-vector = pv-to-iv @values;

  $!ordered = $ordered;
}

method vector() returns Seq {
  @!vector.Seq;
}

method root() returns Numeric {
  return @!vector.head;
}

# method intervals() returns Seq {
#   return Seq unless @!vector.elems > 1;
#   given @!vector[0] -> $root {
#     return @!vector[1..*].map: * - $root;
#   }
# }

method interval-vector() returns Seq {
  @!interval-vector.Seq
}

method repeat-interval() returns Numeric {
  $!repeat-interval;
}

method step(Numeric $step --> Numeric) {
  if $step ~~ Rational {
    # Rats are expensive to string so we will force the following cheaper versoin:
    my Str $key = $step.numerator ~ '/' ~ $step.denominator;
    if %!step-cache{$key}:exists {
      %!step-cache{$key}
    }
    else {
      %!step-cache{$key} = self.ScaleVec::Vector::step($step);
    }
  }
  else {
    if %!step-cache{$step}:exists {
      %!step-cache{$step}
    }
    else {
      %!step-cache{$step} = self.ScaleVec::Vector::step($step);
    }
  }
}

method reflexive-step(Numeric $value --> Numeric) {
  if $value ~~ Rational {
    # Rats are expensive to string so we will force the following cheaper versoin:
    my Str $key = $value.numerator ~ '/' ~ $value.denominator;
    if %!reflexive-cache{$key}:exists {
      %!reflexive-cache{$key}
    }
    else {
      %!reflexive-cache{$key} = self.ScaleVec::Vector::reflexive-step($value);
    }
  }
  else {
    if %!reflexive-cache{$value}:exists {
      %!reflexive-cache{$value}
    }
    else {
      %!reflexive-cache{$value} = self.ScaleVec::Vector::reflexive-step($value);
    }
  }
}

#
# Serialise::Map methods
#

method to-map( --> Map) {
  %(
    vector          => .vector,
    repeat-interval => .repeat-interval,
  ) given self;
}

method from-map(Map $m --> ScaleVec) {
  self.new(|$m)
}
