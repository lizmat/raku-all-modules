[![Build Status](https://travis-ci.org/okaoka/p6-Algorithm-KdTree.svg?branch=master)](https://travis-ci.org/okaoka/p6-Algorithm-KdTree)

NAME
====

Algorithm::KdTree - a perl6 binding for C implementation of the Kd-Tree Algorithm (https://github.com/jtsiomb/kdtree)

SYNOPSIS
========

    use Algorithm::KdTree;

    my $kdtree = Algorithm::KdTree.new(3);

    $kdtree.insert([0e0,0e0,0e0]);
    $kdtree.insert([10e0,10e0,10e0]);

    my $nearest-response = $kdtree.nearest([1e0,1e0,1e0]);
    $nearest-response.set-dimension(3); # must call this method
    if (not $nearest-response.is-end()) {
       $nearest-response.get-position().say; # [0e0, 0e0, 0e0]
    }

    my $range-response = $kdtree.nearest-range([9e0,9e0,9e0], sqrt(5));
    my @array;
    $range-response.set-dimension(3); # must call this method
    while (not $range-response.is-end()) {
       @array.push($range-response.get-position());
       $range-response.next();
    }
    @array.perl.say; # [[10e0, 10e0, 10e0], ]

DESCRIPTION
===========

Algorithm::KdTree is a perl6 binding for C implementation of the Kd-Tree Algorithm (https://github.com/jtsiomb/kdtree). Kd-Tree is the efficient algorithm for searching nearest neighbors in the k-dimensional space.

CONSTRUCTOR
-----------

### new(Int $dimension)

    my $kdtree = Algorithm::KdTree.new(3);
    my $kdtree = Algorithm::KdTree.new(256); # it could handle a huge dimensional space

Sets dimension `$dimension` for constructing `$dimension`-dimensional Kd-Tree.

METHODS
-------

### insert(@array)

    $kdtree.insert([1e0, 2e0, 3e0]);

Inserts a k-dimensional array.

### nearest(@array)

    my $response = $kdtree.nearest([1e0, 2e0, 3e0]);
    $response.set-dimension(3); # must call this method, in this case 3-dimensional Kd-Tree have been constructed.
    if (not $response.is-end()) {
	      my $position = $response.get-position();

    # YOUR CODE IS HERE
    # ...

    }

Returns a response which includes the nearest neighbor position of the query `@array` in the Kd-Tree. If the Kd-Tree has no elements, it returns a response which does not include any positions.

### nearest-range(@array, Num $radius)

    my $response = $kdtree.nearest-range([1e0, 2e0, 3e0], 10e0);
    $response.set-dimension(3); # must call this method
    while (not $response.is-end()) {
	      my $position = $response.get-position();

    # YOUR CODE IS HERE
    # ...

    $response.next();

    }

Returns a response which includes positions in the hypersphere. The center of this hypersphere is `@array` and the radius of this is `$radius`. If the Kd-Tree has no elements or no elements are found in the hypersphere, it returns a response which does not include any positions.

AUTHOR
======

okaoka <cookbook_000@yahoo.co.jp>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 okaoka

Copyright 2007-2011 John Tsiombikas <nuclear@member.fsf.org>

This library is free software; you can redistribute it and/or modify it under the terms of the BSD 3-Clause License.

SEE ALSO
========

  * kdtree [https://github.com/jtsiomb/kdtree](https://github.com/jtsiomb/kdtree)
