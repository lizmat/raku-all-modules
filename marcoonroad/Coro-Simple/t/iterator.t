#!/usr/bin/perl6

use v6;

# array traversal  test

use Test;
use Coro::Simple;

plan 6;

# iterator example
my &iter = coro sub (*@xs) {
    for @xs -> $x {
	say "Yielding $x...\n";
	yield $x;
    }
};

for from iter 3 ... -2 -> $x {
    ok say $x;
    sleep 0.5;
}


# end of test