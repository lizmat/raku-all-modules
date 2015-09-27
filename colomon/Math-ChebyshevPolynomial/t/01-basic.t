use v6;
use Math::ChebyshevPolynomial;
use Test;

plan 33;

{
    my $cp = Math::ChebyshevPolynomial.new(:domain(-1..1), :c((42)));
    isa-ok $cp, Math::ChebyshevPolynomial, ".new makes a proper object";
    is-approx $cp.evaluate(0), 21, "Constant is correctly boring";
    is-approx $cp.evaluate(1/2), 21, "Constant is still correctly boring";
}

{
    my $cp = Math::ChebyshevPolynomial.new(:domain(-1..1), :c((42, 2)));
    is-approx $cp.evaluate(0), 21, "Linear 0 is correct";
    is-approx $cp.evaluate(1/2), 22, "Linear 1/2 is correct";
    is-approx $cp.evaluate(-1/2), 20, "Linear -1/2 is correct";
}

{
    my $cp = Math::ChebyshevPolynomial.new(:domain(-1..1), :c((42, 2, 3)));
    is-approx $cp.evaluate(0), 18, "Quadratic 0 is correct";
    is-approx $cp.evaluate(1/2), 21 + 1 - 3 / 2, "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(-1/2), 21 - 1 - 3 / 2, "Quadratic -1/2 is correct";
}

{
    my &f = -> $x { 3 * $x * $x + 2 * $x + 1 };
    my $cp = Math::ChebyshevPolynomial.approximate(-1..1, 4, &f);
    isa-ok $cp, Math::ChebyshevPolynomial, ".approximate makes a proper object";
    is-approx $cp.evaluate(0), &f(0), "Quadratic 0 is correct";
    is-approx $cp.evaluate(1/2), &f(1/2), "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(-1/2), &f(-1/2), "Quadratic -1/2 is correct";
}

{
    my $cp = Math::ChebyshevPolynomial.approximate(-1..1, 10, &cos);
    isa-ok $cp, Math::ChebyshevPolynomial, ".approximate makes a proper object";
    say $cp.c;
    is-approx $cp.evaluate(0), cos(0), "Quadratic 0 is correct";
    is-approx $cp.evaluate(1/2), cos(1/2), "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(-1/2), cos(-1/2), "Quadratic -1/2 is correct";
}

{
    my $cp = Math::ChebyshevPolynomial.approximate(-1..1, 10, &cos).derivative;
    isa-ok $cp, Math::ChebyshevPolynomial, ".derivative makes a proper object";
    say $cp.c;
    is-approx $cp.evaluate(0), -sin(0), abs_tol => 1e-6, desc => "Quadratic 0 is correct";
    is-approx $cp.evaluate(1/2), -sin(1/2), "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(-1/2), -sin(-1/2), "Quadratic -1/2 is correct";
}

{
    my $cp = Math::ChebyshevPolynomial.approximate(-1..1, 10, &cos).derivative.derivative;
    isa-ok $cp, Math::ChebyshevPolynomial, ".derivative makes a proper object";
    say $cp.c;
    is-approx $cp.evaluate(0), -cos(0), "Quadratic 0 is correct";
    is-approx $cp.evaluate(1/2), -cos(1/2), "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(-1/2), -cos(-1/2), "Quadratic -1/2 is correct";
}

{
    my $cp = Math::ChebyshevPolynomial.approximate(1/4..3/4, 10, &cos);
    isa-ok $cp, Math::ChebyshevPolynomial, ".approximate makes a proper object";
    say $cp.c;
    is-approx $cp.evaluate(1/4), cos(1/4), "Quadratic 1/4 is correct";
    is-approx $cp.evaluate(1/2), cos(1/2), "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(3/4), cos(3/4), "Quadratic 3/4 is correct";
}

{
    my $cp = Math::ChebyshevPolynomial.approximate(1/4..3/4, 10, &cos).derivative;
    isa-ok $cp, Math::ChebyshevPolynomial, ".derivative makes a proper object";
    say $cp.c;
    is-approx $cp.evaluate(1/4), -sin(1/4), "Quadratic 1/4 is correct";
    is-approx $cp.evaluate(1/2), -sin(1/2), "Quadratic 1/2 is correct";
    is-approx $cp.evaluate(3/4), -sin(3/4), "Quadratic 3/4 is correct";
}
