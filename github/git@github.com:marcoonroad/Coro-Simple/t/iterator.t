#!/usr/bin/perl6

use v6;

# array traversal  test

use Test;
use Coro::Simple;

plan 3;

my &iter = coro sub (*@xs) {
    for @xs -> $x {
	say "Yielding $x...\n";
	yield $x;
    }
};

for from iter 1 ... 3 -> $x {
    ok $x;
}

# end of test