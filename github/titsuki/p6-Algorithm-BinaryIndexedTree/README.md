[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-BinaryIndexedTree.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-BinaryIndexedTree)

NAME
====

Algorithm::BinaryIndexedTree - data structure for cumulative frequency tables

SYNOPSIS
========

    use Algorithm::BinaryIndexedTree;

    my $BIT = Algorithm::BinaryIndexedTree.new();
    $BIT.add(5,10);
    $BIT.get(0).say; # 0
    $BIT.get(5).say; # 10
    $BIT.sum(4).say; # 0
    $BIT.sum(5).say; # 10

    $BIT.add(0,10);
    $BIT.sum(5).say; # 20

DESCRIPTION
===========

Algorithm::BinaryIndexedTree is the data structure for maintainig the cumulative frequencies.

CONSTRUCTOR
-----------

### new

    my $BIT = Algorithm::BinaryIndexedTree.new(%options);

#### OPTIONS

  * `size => $size`

Sets table size. Default is 1000.

METHODS
-------

### add

    $BIT.add($index, $value);

Adds given value to the index `$index`.

### sum

    my $sum = $BIT.sum($index);

Returns sum of the values of items from index 0 to index `$index` inclusive.

### get

    my $value = $BIT.get($index);

Returns the value at index `$index`.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from Fenwick, Peter M. "A new data structure for cumulative frequency tables." Software: Practice and Experience 24.3 (1994): 327-336.
