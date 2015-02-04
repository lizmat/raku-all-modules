use v6;
use Math::Polynomial;
use Test;

plan 143;

my $p = Math::Polynomial.new(1.0, 2.0, 3.0);
my $p2 = Math::Polynomial.new(0.0, 0.0, 3.0, 5.0, 6.0);
my $p3 = Math::Polynomial.new();
my $p4 = Math::Polynomial.new(1.0);
my $p5 = Math::Polynomial.new(0, 0, 3, 5, 6, 0.0, 0);

isa_ok($p, Math::Polynomial, "Variable is of type Math::Polynomial");
isa_ok($p2, Math::Polynomial, "Variable is of type Math::Polynomial");
isa_ok($p3, Math::Polynomial, "Variable is of type Math::Polynomial");
isa_ok($p4, Math::Polynomial, "Variable is of type Math::Polynomial");
isa_ok($p5, Math::Polynomial, "Variable is of type Math::Polynomial");

ok $p3.is-zero, "Empty Math::Polynomial.new generates zero polynomial";
is(~$p, "3 x^2 + 2 x^1 + 1 x^0", "Math::Polynomial.Str works correctly");
is(~EVAL($p.perl), ~$p, ".perl works, tested with Str");
isa_ok(EVAL($p.perl), Math::Polynomial, ".perl works, tested with isa");

is($p5.coefficients.elems, 5, "Leading zero coefficients deleted");

is_approx($p.evaluate(0.0), 1.0, "\$p.evaluate(0.0) == 1");
is_approx($p.evaluate(1.0), 6.0, "\$p.evaluate(1.0) == 6");

my $sum = $p + -$p;
ok $sum.is-zero, "p + (-p) is the zero polynomial";

$sum = $p + $p2;

for ^10 -> $x
{
    is_approx($sum.evaluate($x), $p.evaluate($x) + $p2.evaluate($x), "sum = p + p2 for $x");
}

$sum = $sum + 3;  # was +=, but that doesn't work any more
for ^10 -> $x
{
    is_approx($sum.evaluate($x), $p.evaluate($x) + $p2.evaluate($x) + 3, "sum + 3 = p + p2 + 3 for $x");
}

$sum = 5 + $sum;
for ^10 -> $x
{
    is_approx($sum.evaluate($x), $p.evaluate($x) + $p2.evaluate($x) + 8, "5 + (sum + 3) = p + p2 + 8 for $x");
}

$sum = -$sum;
for ^10 -> $x
{
    is_approx($sum.evaluate($x), -($p.evaluate($x) + $p2.evaluate($x) + 8), "-(5 + (sum + 3)) = -(p + p2 + 8) for $x");
}

my $product = $sum * $p4;
for ^10 -> $x
{
    is_approx($product.evaluate($x), $sum.evaluate($x), "sum * (1 x^0) = sum for $x");
}

$product = $sum * $p3;
for ^10 -> $x
{
    is_approx($product.evaluate($x), 0.0, "sum * (0 x^0) = 0 for $x");
}

$product = $sum * 1;
for ^10 -> $x
{
    is_approx($product.evaluate($x), $sum.evaluate($x), "sum * 1 = sum for $x");
}

$product = $sum * 0;
for ^10 -> $x
{
    is_approx($product.evaluate($x), 0.0, "sum * 0 = 0 for $x");
}

$product = 2.5 * $sum;
for ^10 -> $x
{
    is_approx($product.evaluate($x), 2.5 * $sum.evaluate($x), "sum * 2.5 = sum * 2.5 for $x");
}

$product = 1 * $sum;
for ^10 -> $x
{
    is_approx($product.evaluate($x), $sum.evaluate($x), "sum * 1 = sum for $x");
}

$product = 0 * $sum;
for ^10 -> $x
{
    is_approx($product.evaluate($x), 0.0, "sum * 0 = 0 for $x");
}

$product = $p * $p2;
for ^10 -> $x
{
    is_approx($product.evaluate($x), $p.evaluate($x) * $p2.evaluate($x), "product = p * p2 for $x");
}

$product = $product / 5.5;  # was /=, but that doesn't work in current Rakudo
for ^10 -> $x
{
    is_approx($product.evaluate($x), $p.evaluate($x) * $p2.evaluate($x) / 5.5, "product / 5.5 = p * p2 / 5.5 for $x");
}
