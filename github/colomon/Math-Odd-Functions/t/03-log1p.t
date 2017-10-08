use v6;
use Math::OddFunctions;
use Test;

plan 16;

is-approx log1p(0), 0, "log1p(0) == 0";
is-approx log1p(1e-50), 1e-50, "log1p(1e-50) == 1e-50";
is-approx log1p(-1e-50), -1e-50, "log1p(-1e-50) == -1e-50";
is-approx log1p(.5), 0.4054651081, "log1p(.5) == 0.4054651081";
is-approx log1p(-.5), -0.6931471806, "log1p(-.5) == -0.69314718061";
is-approx log1p(1), 0.6931471806, "log1p(1) == 0.6931471806";
is-approx log1p(10), 2.397895273, "log1p(10) == 2.397895273";
is-approx log1p(100), 4.615120517, "log1p(100) == 4.615120517";

is-approx expm1(0), 0, "expm1(0) == 0";
is-approx expm1(1e-50), 1e-50, "expm1(1e-50) == 1e-50";
is-approx expm1(-1e-50), -1e-50, "expm1(-1e-50) == -1e-50";
is-approx expm1(.5), 0.6487212707, "expm1(.5) == 0.6487212707";
is-approx expm1(-.5), -0.3934693403, "expm1(-.5) == -0.3934693403";
is-approx expm1(1), 1.718281828, "expm1(1) == 1.718281828";
is-approx expm1(10), 22025.46579, "expm1(10) == 22025.46579";
is-approx expm1(100), 2.688117142e+43, "expm1(100) == 2.688117142e+43";

