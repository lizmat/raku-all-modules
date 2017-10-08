use Math::Sequences::Real;

use Test;

plan(5);

is ℝ.elems, Inf, "Infinite reals";
is ℝ.of, ::Real, "Reals get Real";
is ~ℝ, "ℝ", "Reals are named ℝ";
is ~Reals.new, "ℝ", "Real Reals are named ℝ";
is ℝ.from(pi)[0], pi, "First real .from range";

# vim: sw=4 softtabstop=4 expandtab ai ft=perl6
