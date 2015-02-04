use v6;
use Math::OddFunctions;
use Test;

plan 22;

is error-function(0), 0, "Erf(0) == 0";
is_approx error-function(.5), .5205, "Erf(.5) == 0.5205";
is_approx error-function(-.5), -.5205, "Erf(-.5) == -0.5205";
is_approx error-function(1), .842701, "Erf(1) == 0.842701";
is_approx error-function(-1), -.842701, "Erf(-1) == -0.842701";
is_approx error-function(10), 1, "Erf(10) == ~1";
is_approx error-function(-10), -1, "Erf(-10) == ~-1";
is_approx error-function(100), 1, "Erf(100) == ~1";
is_approx error-function(-100), -1, "Erf(-100) == ~-1";
is_approx error-function(10**100000), 1, "Erf(10**100000) == ~1";
is_approx error-function(-10**100000), -1, "Erf(-10**100000) == ~-1";

is complementary-error-function(0), 1, "Erfc(0) == 1";
is_approx complementary-error-function(.5), 0.4795, "Erfc(.5) == 0.4795";
is_approx complementary-error-function(-.5), 1.5205, "Erfc(-.5) == 1.5205";
is_approx complementary-error-function(1), 0.1572992, "Erfc(1) == 0.1572992";
is_approx complementary-error-function(-1), 2 - 0.1572992, "Erfc(-1) == 2 - 0.1572992";
is_approx complementary-error-function(10), 2.08849e-45, "Erfc(10) == 2.08849e-45";
is_approx complementary-error-function(-10), 2 - 2.08849e-45, "Erfc(-10) == 2 - 2.08849e-45";
is_approx complementary-error-function(100), 0, "Erfc(100) == ~0";
is_approx complementary-error-function(-100), 2, "Erfc(-100) == ~2";
is_approx complementary-error-function(10**100000), 0, "Erfc(10**100000) == ~0";
is_approx complementary-error-function(-10**100000), 2, "Erfc(-10**100000) == ~2";
