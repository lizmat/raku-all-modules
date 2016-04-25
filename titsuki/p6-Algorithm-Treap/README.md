[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-Treap.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-Treap)

NAME
====

Algorithm::Treap - randomized search tree

SYNOPSIS
========

    use Algorithm::Treap;

    # store Int key
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0);
    $treap.insert(1, 10);
    $treap.insert(2, 20);
    $treap.insert(3, 30);
    $treap.insert(4, 40);
    my $value = $treap.find-value(3); # 30
    my $first-key = $treap.find-first-key(); # 0
    my $last-key = $treap.find-last-key(); # 4

    # delete
    $treap.delete(4);

    # store Str key
    my $treap = Algorithm::Treap.new(key-type => Str);
    $treap.insert('a', 0);
    $treap.insert('b', 10);
    $treap.insert('c', 20);
    $treap.insert('d', 30);
    $treap.insert('e', 40);
    my $value = $treap.find-value('a'); # 0
    my $first-key = $treap.find-first-key(); # 'a'
    my $last-key = $treap.find-last-key(); # 'e'

    # delete
    $treap.delete('c');

DESCRIPTION
===========

Algorithm::Treap is a implementation of the Treap algorithm. Treap is the one of the self-balancing binary search tree. It employs a randomized strategy for maintaining balance.

CONSTRUCTOR
-----------

### new

    my $treap = Algorithm::Treap.new(%options);

#### OPTIONS

  * `key-type => Int|Str`

Sets either one of the type objects(Int or Str) for keys which you use to insert items to the treap.

  * `order-by => 'asc'|'desc'`

Sets key order 'asc' or 'desc' in the treap. Default is 'asc'.

METHODS
-------

### insert

    $treap.insert($key, $value);

Inserts the key-value pair to the treap. If the treap already has the same key, it overwrites existing one.

### delete

    $treap.delete($key);

Deletes the node associated with the key from the treap.

### find-value

    my $value = $treap.find-value($key);

Returns the value associated with the key in the treap. When it doesn't hit any keys, it returns type object Any.

### find

    my $node = $treap.find($key);

Returns the instance of the Algorithm::Treap::Node associated with the key in the treap. When it doesn't hit any keys, it returns type object Any.

### find-first-key

    my $first-key = $treap.find-first-key();

Returns the first key in the treap.

### find-last-key

    my $last-key = $treap.find-last-key();

Returns the last key in the treap.

METHODS NOT YET IMPLEMENTED
===========================

join, split, finger-search, sort

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from Seidel, Raimund, and Cecilia R. Aragon. "Randomized search trees." Algorithmica 16.4-5 (1996): 464-497.
