#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Scheme::Gambit;

my $gambit = Inline::Scheme::Gambit.new();
$gambit.run(q{
        (define (fib n)
         (if (< n 2) n (+ (fib (- n 1)) (fib (- n 2)))))
    });
is $gambit.call('fib', 8), 21;
is $gambit.call('map', $gambit.run(q{(lambda (n) (fib n))}), [0 .. 8]), [0, 1, 1, 2, 3, 5, 8, 13, 21];

dies-ok { $gambit.call("+", 1, "foo") }, "dies from scheme";

done-testing;
