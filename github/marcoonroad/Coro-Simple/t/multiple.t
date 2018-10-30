#!/usr/bin/perl6

use v6;

# a test that yields multiple values

use Test;
use Coro::Simple;

plan 7;

my &transform = coro sub (&fn, *@xs) {
    for @xs -> $x, $y, $z {
        fn $x;
        fn $y;
        fn $z;
    }
}

my &get-next = transform -> $x {
    yield [ $x, $x + 1, $x ** 2 ] # will yields an anonymous list
}, (45 ... 15);

my $items;

for ^7 {
    $items = get-next;
    ok defined $items;
    say $items;
}

# end of test