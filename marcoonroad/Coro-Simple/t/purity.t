#!/usr/bin/perl6

use v6;

# a test that has minimal side-effects

use Test;
use Coro::Simple;

plan 10;

# pure generator function (read-only bind)
my &pure-gen ::= coro -> $x {
    my &recurse;

    &recurse = -> $n {
	yield $n;
	return recurse $n + 1;
    }

    recurse $x;
}

# pure loop-construct like function
sub clock (&block, [ $i, $f ]) {
    return unless $i <= $f;
    block $i;
    return clock &block, [ $i + 1, $f ];
}

# generator function
my $get = pure-gen 10;

# generates an error
# &pure-gen = { };

my $result;

# impure block in loop
clock -> $i {
    $result = $get( ); # impure, mutable variable
    ok defined $result;
    say [ $i, $result ];
    sleep 0.5;
}, [ 1, 10 ];

# end of test