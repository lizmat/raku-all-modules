use v6.c;
unit class Math::Curves:ver<0.0.1>;

=begin pod

=head1 NAME

Math::Curves - Simple functions for simple curves.

=head1 SYNOPSIS

  use Math::Curves;

  # find the point 1/3 along a linear bézier function.
  #   Transition, p0   p1
  bézier 1/3,     0,  40;

  # find the point 1/3 along a quadratic bézier function.
  #   Transition, p0  p1   p2
  bézier 1/3,     0,  40,  30;

  # find the point 1/3 along a cubic bézier function.
  #   Transition, p0  p1  p2   p4
  bézier 1/3,     0,  40, 30, -10.5;

  # find the point 1/3 along a bézier curve of any size > 1.
  #   Transition,  p0  p1  p2   ...
  bézier 1/3,     (0,  40, 30, -10.5,  18.28);

  # Calculate the length of a line with a given gradient
  #    position(x)  gradient
  line 2,           1/1;

=head1 DESCRIPTION

Math::Curves provides some simple functions for plotting points on a curve.
The methods above are the only functions currently implemented but I hope to see this list grow over time.

=head1 Contributing

This module is still quite incomplete so please contribute your favourite functions!
To do so submit a pull request to the repo on github: https://github.com/samgwise/p6-Math-Curves

Contributors will be credited and appreciated :)

=head1 AUTHOR

 Sam Gillespie

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

my subset Transition of Rat where { 0 <= $_ and $_ <= 1 }

sub line(Numeric $x, Rat $gradient --> Rat) is export {
  $x + ($x * $gradient)
}

#linear
multi sub bézier(Transition $t, Numeric $p0, Numeric $p1 --> Rat) is export {
  $p0 + ($t * ($p1 - $p0))
}
#quadratic
multi sub bézier(Transition $t, Numeric $p0, Numeric $p1, Numeric $p2 --> Rat) is export {
  ((1 - $t) ** 2) * $p0
  + (2 * (1 - $t)) * $t * $p1
  + ($t ** 2) * $p2
}
#cubic
multi sub bézier(Transition $t, Numeric $p0, Numeric $p1, Numeric $p2, Numeric $p3 --> Rat) is export {
  ((1 - $t) ** 3) * $p0
  + (3 * ((1 - $t) ** 2)) * $t * $p1
  + (3 * (1 - $t) ) * ($t ** 2) * $p2
  + ($t ** 3) * $p3
}
#generlised
multi sub bézier(Transition $t, List $points --> Rat) is export {
  given $points.elems {
    when * < 2 {
      die "Generilsed Bézier requires 2 or more elements in point list!";
    }
    when * % 2 == 0 {
        given $points.elems {
          when 4 {
            bézier $t, $points[0], $points[1], $points[2], $points[3]
          }
          when 2 {
            bézier $t, $points[0], $points[1]
          }
          default {
            bézier $t, bézier($t, $points[0], $points[1]), bézier($t, $points[2..*]);
          }
        }
    }
    default {
      given $points.elems {
        when 3 {
          bézier($t, $points[0], $points[1], $points[2])
        }
        default {
          bézier $t, $points[0], bézier($t, $points[1..*])
        }
      }
    }
  }
}
