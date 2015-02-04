#!/usr/bin/perl6

use v6;

# a range generator test

use Test;
use Coro::Simple;

plan 5;

# range coroutine
my &xrange = coro -> $min, $max, $step {
    for $min, $min + $step ...^ $max -> $num {
	yield $num;
    }
}

# generator function
my $next = xrange (20, 30, 2);

# first result
my $value = $next( );

# loop until $item becomes a Bool
# value, delaying 0.5 second by cycle
while $value ~~ Int {
    ok defined $value;
    say $value;
    $value = $next( );
    sleep 0.5;
}

# end of test