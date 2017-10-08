#!/usr/bin/perl6

use v6;

# "casts" a generator to lazy array

use Test;
use Coro::Simple;

plan 3;

my &iter = coro sub (*@xs) {
    for @xs -> $x {
        say "Yay! You get $x.";
        yield $x;
    }
}

my $next = iter 3 ... -2;

my @array := (from $next).map(* + 1).list; # bind the lazy array returned

ok @array[ 0 ] == 4;
ok @array[ 1 ] == 3;
ok @array[ 2 ] == 2;

# end of test
