#!perl6

use v6;
use lib 'lib';

use Test;

plan 17;

use-ok "Math::PascalTriangle";
use Math::PascalTriangle;

is Math::PascalTriangle.get(:line(0):col(0)), 1;
is Math::PascalTriangle.cached-lines, 1;
is Math::PascalTriangle.get(:line(1):col(0)), 1;
is Math::PascalTriangle.cached-lines, 1;
is Math::PascalTriangle.get(:line(1):col(1)), 1;
is Math::PascalTriangle.cached-lines, 1;
is Math::PascalTriangle.get(:line(2):col(1)), 2;
is Math::PascalTriangle.cached-lines, 3;
is Math::PascalTriangle.get(:line(4):col(2)), 6;
is Math::PascalTriangle.cached-lines, 5;
is Math::PascalTriangle.get(:line(999999):col(0)), 1, "any get with col 0 should calculate nothing and return 1";
is Math::PascalTriangle.cached-lines, 5;
is Math::PascalTriangle.get(:line(999999):col(999999)), 1, "any get with col equal to line should calculate nothing and return 1";
is Math::PascalTriangle.cached-lines, 5;

dies-ok {Math::PascalTriangle.get(:line(1):col(2))}, "Do not accept col bigger than line";
lives-ok {Math::PascalTriangle.get(:line(2):col(2))}, "Accept col equal to line";
