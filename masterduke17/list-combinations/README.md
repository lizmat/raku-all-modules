# List::Combinations
A very simple implementation of `combinations()`, that nevertheless is a bit
faster, at the expense of creating an Array instead of a Seq.

Also, an iterative Heap's algorithm implementation of `permutations()`, that
also is faster, at the expense of creating an Array instead of a Seq.

## Synopsis
```
use List::Combinations;

# All $of-combinations of @list
my @combinations = combos(@list, $of);

# All $of-combinations of ^$n
my @combinations = combos($n, $of);

# All permutations of @list
my @permutations = perms(@list);

# All permutations of ^$n
my @permutations = perms($n);
```

## Copyright & License
Copyright 2016 Daniel Green.

This module may be used under the terms of the Artistic License 2.0.
