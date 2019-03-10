[![Build Status](https://travis-ci.org/titsuki/p6-Random-Choice.svg?branch=master)](https://travis-ci.org/titsuki/p6-Random-Choice)

NAME
====

Random::Choice - A Perl 6 alias method implementation

SYNOPSIS
========

```perl6
use Random::Choice;

say choice(:size(5), :p([0.1, 0.1, 0.1, 0.7])); # (3 3 3 0 1)
say choice(:p([0.1, 0.1, 0.1, 0.7])); # 3
```

DESCRIPTION
===========

Random::Choice is a Perl 6 alias method implementation. Alias method is an efficient algorithm for sampling from a discrete probability distribution.

METHODS
-------

### choice

Defined as:

    multi sub choice(:@p! --> Int) is export
    multi sub choice(Int :$size!, :@p! --> List)

Returns a sample which is an Int value or a List. Where `:@p` is the probabilities associated with each index and `:$size` is the sample size.

FAQ
===

Is `Random::Choice` faster than Mix.roll?
-----------------------------------------

The answer is YES when you roll a large biased dice or try to roll a dice many times; but NO when a biased dice is small or try to roll a dice few times.

Why? There are some possible reasons:

  * `Random::Choice` employs O(N) + O(1) algorithm whereas `Mix.roll` employs O(N) + O(N) algorithm (rakudo 2018.12).

  * `Mix.roll` is directly written in nqp. In general, nqp-powered code is faster than naive-Perl6-powered code when they take small input.

  * Both algorithms take O(N) initialization cost; however, the actual cost of `Mix.roll` is slightly less than `Random::Choice`.

A benchmark result is here (For more info, see `example/bench.p6`):

```bash
$ perl6 example/bench.p6 
Benchmark: 
Timing 1000 iterations of Mix(size=10, @p.elems=10) , Random::Choice(size=10, @p.elems=10)...
Mix(size=10, @p.elems=10) : 0.120 wallclock secs (0.146 usr 0.006 sys 0.152 cpu) @ 8335.278/s (n=1000)
Random::Choice(size=10, @p.elems=10): 0.249 wallclock secs (0.286 usr 0.003 sys 0.288 cpu) @ 4015.613/s (n=1000)
O--------------------------------------O--------O----------------------------O--------------------------------------O
|                                      | Rate   | Mix(size=10, @p.elems=10)  | Random::Choice(size=10, @p.elems=10) |
O======================================O========O============================O======================================O
| Mix(size=10, @p.elems=10)            | 8335/s | --                         | -58%                                 |
| Random::Choice(size=10, @p.elems=10) | 4016/s | 140%                       | --                                   |
O--------------------------------------O--------O----------------------------O--------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=1000, @p.elems=10) , Random::Choice(size=1000, @p.elems=10)...
Mix(size=1000, @p.elems=10) : 2.794 wallclock secs (2.792 usr 0.000 sys 2.792 cpu) @ 357.965/s (n=1000)
Random::Choice(size=1000, @p.elems=10): 0.238 wallclock secs (0.238 usr 0.004 sys 0.242 cpu) @ 4201.204/s (n=1000)
O----------------------------------------O--------O------------------------------O----------------------------------------O
|                                        | Rate   | Mix(size=1000, @p.elems=10)  | Random::Choice(size=1000, @p.elems=10) |
O========================================O========O==============================O========================================O
| Mix(size=1000, @p.elems=10)            | 358/s  | --                           | 1215%                                  |
| Random::Choice(size=1000, @p.elems=10) | 4201/s | -92%                         | --                                     |
O----------------------------------------O--------O------------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=10, @p.elems=1000) , Random::Choice(size=10, @p.elems=1000)...
Mix(size=10, @p.elems=1000) : 3.570 wallclock secs (3.539 usr 0.028 sys 3.566 cpu) @ 280.119/s (n=1000)
Random::Choice(size=10, @p.elems=1000): 15.011 wallclock secs (14.992 usr 0.012 sys 15.004 cpu) @ 66.619/s (n=1000)
O----------------------------------------O--------O------------------------------O----------------------------------------O
|                                        | Rate   | Mix(size=10, @p.elems=1000)  | Random::Choice(size=10, @p.elems=1000) |
O========================================O========O==============================O========================================O
| Mix(size=10, @p.elems=1000)            | 280/s  | --                           | -76%                                   |
| Random::Choice(size=10, @p.elems=1000) | 66.6/s | 323%                         | --                                     |
O----------------------------------------O--------O------------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=100, @p.elems=100), Random::Choice(size=100, @p.elems=100)...
Mix(size=100, @p.elems=100): 2.303 wallclock secs (2.305 usr 0.000 sys 2.305 cpu) @ 434.278/s (n=1000)
Random::Choice(size=100, @p.elems=100): 1.578 wallclock secs (1.577 usr 0.000 sys 1.577 cpu) @ 633.811/s (n=1000)
O----------------------------------------O-------O-----------------------------O----------------------------------------O
|                                        | Rate  | Mix(size=100, @p.elems=100) | Random::Choice(size=100, @p.elems=100) |
O========================================O=======O=============================O========================================O
| Mix(size=100, @p.elems=100)            | 434/s | --                          | 47%                                    |
| Random::Choice(size=100, @p.elems=100) | 634/s | -32%                        | --                                     |
O----------------------------------------O-------O-----------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=1000, @p.elems=1000), Random::Choice(size=1000, @p.elems=1000)...
Mix(size=1000, @p.elems=1000): 186.849 wallclock secs (186.608 usr 0.124 sys 186.731 cpu) @ 5.352/s (n=1000)
Random::Choice(size=1000, @p.elems=1000): 14.920 wallclock secs (14.897 usr 0.012 sys 14.909 cpu) @ 67.025/s (n=1000)
O------------------------------------------O--------O-------------------------------O------------------------------------------O
|                                          | Rate   | Mix(size=1000, @p.elems=1000) | Random::Choice(size=1000, @p.elems=1000) |
O==========================================O========O===============================O==========================================O
| Mix(size=1000, @p.elems=1000)            | 5.35/s | --                            | 1155%                                    |
| Random::Choice(size=1000, @p.elems=1000) | 67.0/s | -92%                          | --                                       |
O------------------------------------------O--------O-------------------------------O------------------------------------------O
```

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

  * Vose, Michael D. "A linear algorithm for generating random numbers with a given distribution." IEEE Transactions on software engineering 17.9 (1991): 972-975.

