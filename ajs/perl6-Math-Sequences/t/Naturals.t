use Math::Sequences::Integer;

use Test;

plan 3;

subtest {
    plan 10;

    is 𝕀.elems, Inf, "Infinite naturals";
    is 𝕀.of, ::Int, "Naturals are Ints";
    is 𝕀.Str, "𝕀", "Naturals are named ℕ";
    is 𝕀[1], 1, "Indexing ℕ";
    for 𝕀 -> $i {
        state $n = 0;
        is $i, $n, "ℕ[$n] should be $n";
        last if $n++ > 2;
    }
    is 𝕀.min, 0, "𝕀.min zero";
    is 𝕀.max, Inf, "𝕀.min infinite";
}, "𝕀";

subtest {
    plan 5;

    is ℕ[0], 1, "Whole numbers[0]";
    is ℕ[1], 2, "Whole numbers[1]";
    is ℕ[2], 3, "Whole numbers[2]";
    is ℕ.min, 1, "Wholes.min 1";
    is ℕ.max, Inf, "Wholes.max infinite";
}, "ℕ";

is 𝕀.from(20)[1], 21, "Arbitrary starting point";

# vim: sw=4 softtabstop=4 expandtab ai ft=perl6
