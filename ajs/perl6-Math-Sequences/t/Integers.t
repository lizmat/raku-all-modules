use Math::Sequences::Integer;

use Test;

plan(3);

is ℤ.elems, Inf, "Infinite integers";
is ℤ.of, ::Int, "Integers are Ints";
is ℤ.Str, "ℤ", "Integers are named ℤ";

# vim: sw=4 softtabstop=4 expandtab ai ft=perl6
