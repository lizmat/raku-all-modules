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

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

  * Vose, Michael D. "A linear algorithm for generating random numbers with a given distribution." IEEE Transactions on software engineering 17.9 (1991): 972-975.

