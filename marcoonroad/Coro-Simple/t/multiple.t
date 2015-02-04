#!/usr/bin/perl6

use v6;

# a test that yields multiple values

use Test;
use Coro::Simple;

plan 9;

# map-like example
my &transform = coro sub (&fn, *@xs) {
    for @xs -> $x, $y, $z {
        fn $x;
        fn $y;
        fn $z;
    }
}

# constructor use
my &get-next = transform -> $x {
    yield [ $x, $x + 1, $x ** 2 ] # will yields an anonymous list
}, (45 ... 15);

my $items;

# iterating with delays of 1/2 second
for ^9 {
    $items = get-next;
    ok defined $items;
    say $items;
    sleep 0.5;
}

# end of test