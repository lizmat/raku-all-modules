#! /usr/bin/env perl6
use v6;
use Test;

use-ok 'Math::Curves';
use Math::Curves;

given (0, 2, 4, 6, 8) -> @results {
  for @results.kv -> $x1, $x2 {
    #positive x
    is line($x1, 1/1), $x2, "Line from $x1 with gradient 1/1";
    #negative x
    is line(-$x1, 1/1), -$x2, "Line from -$x1 with gradient 1/1";
  }
}

#
# Bézier curves
#
is bézier(1/2, 1, 1),     1, "Linear Bézier curves 1 to 1 with t = 1/2 is 1";
is bézier(1/2, -1, 1),    0, "Linear Bézier curves -1 to 1 with t = 1/2 is 0";
is bézier(1/2, 10, -10),  0, "Linear Bézier curves 10 to -10 with t = 1/2 is 0";
is bézier(1/2, 10, 0),    5, "Linear Bézier curves 10 to 1 with t = 1/2 is 5";
is bézier(1/2, 0, 20),   10, "Linear Bézier curves 1 to 20 with t = 1/2 is 10";

is bézier(1/2, 1, 1, 1),    1,    "Quadratic Bézier curves along 1, 1, 1 with t = 1/2 is 1";
is bézier(1/2, -1, 0, 1),   0,    "Quadratic Bézier curves along -1, 0, 1 with t = 1/2 is 0";
is bézier(1/2, 10, 0, -10), 0,    "Quadratic Bézier curves along 10, 0, -10 with t = 1/2 is 0";
is bézier(1/2, 5, 0, 5),    2.5,  "Quadratic Bézier curves along 5, 0, 5 with t = 1/2 is 2.5";

is bézier(1/2, 1, 1, 1, 1),     1,    "Cubic Bézier curves along 1, 1, 1, 1 with t = 1/2 is 1";
is bézier(1/2, -1, 0, 0, 1),    0,    "Cubic Bézier curves along -1, 0, 0, 1 with t = 1/2 is 0";
is bézier(1/2, 10, 5, -5, -10), 0,    "Cubic Bézier curves along 10, 5, -5, -10 with t = 1/2 is 0";
is bézier(1/2, 5, 0, 3, 5),     2.375,"Cubic Bézier curves along 5, 0, 0, 5 with t = 1/2 is 2.5";

is bézier(1/2, (1, 1)),       bézier(1/2, 1, 1),       "Linear and generalised Bézier curves match";
is bézier(1/2, (1, 1, 1)),    bézier(1/2, 1, 1, 1),    "Quadratic and generalised Bézier curves match";
is bézier(1/2, (1, 1, 1, 1)), bézier(1/2, 1, 1, 1, 1), "Cubic and generalised Bézier curves match";

# Test a few extra dimensions
{
  my @values = 1, 1;
  for 1..10 {
    is bézier(1/2, @values), 1, "Generalised Bézier curves along { @values.join: ', ' } with t = 1/2 is 1";
    @values.push: 1;
  }
}
is bézier(1/2, (-100, 100)), 0, "Generalised Bézier curve along -100, 100 with t = 1/2 is 0";
is bézier(1/2, (-100, 100, -100, 100)), 0, "Generalised Bézier curve along -100, 100, -100, 100 with t = 1/2 is 0";
is bézier(1/2, (-100, 100, -100, 100, -100, 100)), 0, "Generalised Bézier curve along -100, 100, -100, 100, -100, 100 with t = 1/2 is 0";

is bézier(1/1, (0, 3, 2, 5, 4, 7)), 7, "Generalised Bézier curve along 0, 3, 2, 5, 4, 7 with t = 1/1 is 7";
is bézier(0/1, (0, 3, 2, 5, 4, 7)), 0, "Generalised Bézier curve along 0, 3, 2, 5, 4, 7 with t = 0/1 is 0";
is bézier(1/2, (0, 3, 2, 5, 4, 7)), 3, "Generalised Bézier curve along 0, 3, 2, 5, 4, 7 with t = 1/2 is 3";

is bézier(1/1, (0, 3, 5, 3, 2, 4, 7)), 7, "Generalised Bézier curve along 0, 3, 5, 3, 2, 4, 7 with t = 1/1 is 7";
is bézier(0/1, (0, 3, 5, 3, 2, 4, 7)), 0, "Generalised Bézier curve along 0, 3, 5, 3, 2, 4, 7 with t = 0/1 is 0";
is bézier(1/2, (0, 3, 5, 3, 2, 4, 7)), 1.875, "Generalised Bézier curve along 0, 3, 5, 3, 2, 4, 7 with t = 1/2 is 1.875";

done-testing
