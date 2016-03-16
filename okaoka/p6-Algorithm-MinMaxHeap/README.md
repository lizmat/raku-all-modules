[![Build Status](https://travis-ci.org/okaoka/p6-Algorithm-MinMaxHeap.svg?branch=master)](https://travis-ci.org/okaoka/p6-Algorithm-MinMaxHeap)

NAME
====

Algorithm::MinMaxHeap - double ended priority queue

SYNOPSIS
========

    use Algorithm::MinMaxHeap;

    my $heap = Algorithm::MinMaxHeap.new();
    $heap.insert(0);
    $heap.insert(1);
    $heap.insert(2);
    $heap.insert(3);
    $heap.insert(4);
    $heap.insert(5);
    $heap.insert(6);
    $heap.insert(7);
    $heap.insert(8);

    $heap.find-max.say # 8;
    $heap.find-min.say # 0;

    my @array;
    while (not $heap.is-empty()) {
	    @array.push($heap.pop-max);
    }
    @array.say # [8, 7, 6, 5, 4, 3, 2, 1, 0]

DESCRIPTION
===========

Algorithm::MinMaxHeap is a simple implementation of double ended priority queue.

CONSTRUCTOR
-----------

    my $heap = MinMaxHeap.new();

METHODS
-------

### insert(Int:D $value)

    $heap.insert($value);

Inserts a value to the queue.

### pop-max()

    my $max-value = $heap.pop-max();

Returns a maximum value in the queue and deletes this value in the queue.

### pop-min()

    my $min-value = $heap.pop-min();

Returns a minimum value in the queue and deletes this value in the queue.

### find-max()

    my $max-value = $heap.find-max();

Returns a maximum value in the queue.

### find-min()

    my $min-value = $heap.find-min();

Returns a minimum value in the queue.

### is-empty() returns Bool:D

    while (not is-empty()) {
	         // YOUR CODE
    }

Returns whether the queue is empty or not.

AUTHOR
======

okaoka <cookbook_000@yahoo.co.jp>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Atkinson, Michael D., et al. "Min-max heaps and generalized priority queues." Communications of the ACM 29.10 (1986): 996-1000.
