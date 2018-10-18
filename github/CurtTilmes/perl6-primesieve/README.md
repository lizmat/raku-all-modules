Math::Primesieve
================

Perl 6 bindings for [primesieve](http://primesieve.org/).


primesieve generates primes using a highly optimized <a
href="http://en.wikipedia.org/wiki/Sieve_of_Eratosthenes">sieve of
Eratosthenes</a> implementation. It counts the primes below 10¹⁰ in
just 0.45 seconds on an Intel Core i7-6700 CPU (4 x 3.4GHz).
primesieve can generate primes and <a
href="http://en.wikipedia.org/wiki/Prime_k-tuple">prime k-tuplets</a>
up to 2⁶⁴.

USAGE
=====

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

Pass options :twins, :triplets, :quadruplets, :quintuplets,
:sextuplets to `count` or `print` for prime k-tuplets.

Iterator
========

    my $iterator = Math::Primesieve::iterator.new;

    say $iterator.next for ^10;   # Print first 10 primes;

    $iterator.skipto(1000);       # skip to a specific start (can also
                                  # specify stop_hint)

    say $iterator.next for ^10;   # Print 10 primes over 1000

    say $iterator.prev for ^10;   # Previous primes

    my $it = Math::Primesieve::iterator.new(1000); # Can start at a num

INSTALLATION
============

First install the
[primesieve](https://github.com/kimwalisch/primesieve) library.

Then install this module in the normal way with zef.

    zef install Math::Primesieve


