[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-SetUnion.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-SetUnion)

NAME
====

Algorithm::SetUnion - a perl6 implementation for solving the disjoint set union problem (a.k.a. Union-Find Tree)

SYNOPSIS
========

    use Algorithm::SetUnion;

    my $set-union = Algorithm::SetUnion.new(size => 5);
    $set-union.union(0,1);
    $set-union.union(1,2);

    my $root = $set-union.find(0);

DESCRIPTION
===========

Algorithm::SetUnion is a perl6 implementation for solving the disjoint set union problem (a.k.a. Union-Find Tree).

CONSTRUCTOR
-----------

    my $set-union = Algorithm::SetUnion.new(%options);

### OPTIONS

  * `size => $size`

Sets the number of disjoint sets.

METHODS
-------

### find(Int $index) returns Int:D

    my $root = $set-union.find($index);

Returns the name(i.e. root) of the set containing element `$index`.

### union(Int $left-index, Int $right-index) returns Bool:D

    $set-union.union($left-index, $right-index);

Unites sets containing element `$left-index` and `$right-index`. If sets are equal, it returns False otherwise True.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Tarjan, Robert Endre. "A class of algorithms which require nonlinear time to maintain disjoint sets." Journal of computer and system sciences 18.2 (1979): 110-127.
