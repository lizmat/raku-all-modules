#!/usr/bin/env perl6

use v6;

use Math::Primesieve;

my $p = Math::Primesieve.new;

say "Using libprimesieve version $p.version()";

say $p.primes(100);           # Primes under 100

say $p.primes(100, 200);      # Primes between 100 and 200

say $p.n-primes(20);          # First 20 primes

say $p.n-primes(10, 1000);    # 10 primes over 1000

say $p.nth-prime(10);         # nth-prime

say $p[10];                   # Can also just subscript for nth-prime

say $p.nth-prime(100, 1000);  # 100th prime over 1000

say $p.count(10**9);          # Count primes under 10^9

$p.print(10);                 # Print primes under 10

say $p.count(10**8, 10**9);   # Count primes between 10^8 and 10^9

$p.print(10, 20);             # Print primes between 10 and 20
