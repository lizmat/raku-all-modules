#!/usr/bin/perl6

use v6;

# a test that yields values from a stream

use Test;
use Coro::Simple;

plan 3;

# lazy fibonacci sequence generator
my &gen-fib = coro sub ( ) {
    my @xs := (1, 1, *+* ... *).list;
    yield $_ for @xs;
};

my $get = gen-fib( );

ok $get( ) for 1 ... 3;

# end of test
