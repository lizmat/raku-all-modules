use v6.c;

use List::MoreUtils <reduce_1>;
use Test;

plan 1;

{
    my @values = 2, 4, 6, 5, 3;
    my $product = reduce_1 -> $a, $b { $a * $b }, @values;
    is $product, 720, "the product";
}

# vim: ft=perl6 expandtab sw=4
