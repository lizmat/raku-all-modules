#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Scheme::Gambit;

my $gambit = Inline::Scheme::Gambit.new();
$gambit.run(q{
        (define (fib n)
         (if (< n 2) n (+ (fib (- n 1)) (fib (- n 2)))))
    });
is $gambit.run('(* 2 (fib 8))'), 42;

dies-ok { $gambit.run('(+ 1 2') }, "dies on wrong expression";

done-testing;
