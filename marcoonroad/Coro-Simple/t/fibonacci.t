#!/usr/bin/perl6

use v6;

# a test that yields values from a stream

use Test;
use Coro::Simple;

plan 15;

# TODO: fix the 'coro' to accept streams

# lazy fibonacci sequence generator
my &fibonacci = coro {
    my @xs := ^2, * + * ... *;
    yield $_ for @xs;
};

# generator function
my $get = fibonacci;

my $result;

# will generates the first 15
# numbers from fibonacci sequence
# (per 1/2 sec of delay, each)
for ^15 {
    $result = $get( );
    ok defined $result;
    say $result;
    sleep 0.5;
}

# end of test