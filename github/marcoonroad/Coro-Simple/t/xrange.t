#!/usr/bin/perl6

use v6;

# a range generator test

use Test;
use Coro::Simple;

plan 5;

my &xrange = coro -> $min, $max, $step {
    for $min, $min + $step ...^ $max -> $num {
	yield $num;
    }
}

my $next = xrange (20, 30, 2);

# first result
my $value = $next( );

# loop until $item becomes False
while $value {
    ok defined $value;
    say $value;
    $value = $next( );
}

# end of test