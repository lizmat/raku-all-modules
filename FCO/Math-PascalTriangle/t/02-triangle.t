#!perl6

use v6;
use lib 'lib';

use Test;

plan 13;

use-ok "Math::PascalTriangle";
use Math::PascalTriangle;

is Math::PascalTriangle.get(:line(0):col(0)), 1, ":line(0):col(0)";
is Math::PascalTriangle.get(:line(1):col(0)), 1, ":line(1):col(0)";
is Math::PascalTriangle.get(:line(1):col(1)), 1, ":line(1):col(1)";
is Math::PascalTriangle.get(:line(2):col(1)), 2, ":line(2):col(1)";
is Math::PascalTriangle.get(:line(4):col(2)), 6, ":line(4):col(2)";
is Math::PascalTriangle.get(:line(999999):col(0)), 1, "any get with col 0 should calculate nothing and return 1";
is Math::PascalTriangle.get(:line(999999):col(999999)), 1, "any get with col equal to line should calculate nothing and return 1";
is Math::PascalTriangle.get(:line(99):col(98)), 99, "very big number";
is Math::PascalTriangle.get(:line(99):col(49)), 50445672272782096667406248628, "very big number";
is Math::PascalTriangle.get(:line(9):col(4)), 126, "not so big number";

dies-ok {Math::PascalTriangle.get(:line(1):col(2))}, "Do not accept col bigger than line";
lives-ok {Math::PascalTriangle.get(:line(2):col(2))}, "Accept col equal to line";
