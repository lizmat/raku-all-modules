[![Build Status](https://travis-ci.org/cono/p6-algorithm-heap-binary.svg?branch=master)](https://travis-ci.org/cono/p6-algorithm-heap-binary)

NAME
====

Algorithm::Heap::Binary - Implementation of a BinaryHeap

SYNOPSIS
========

        use Algorithm::Heap::Binary;

        my Algorithm::Heap::Binary $heap .= new(
            comparator => * <=> *,
            3 => 'c',
            2 => 'b',
            1 => 'a'
        );

        $heap.size.say; # 3

        # heap-sort example
        $heap.delete-min.value.say; # a
        $heap.delete-min.value.say; # b
        $heap.delete-min.value.say; # c

DESCRIPTION
===========

Algorithm::Heap::Binary provides to you BinaryHeap data structure with basic heap operations defined in Algorithm::Heap role:

peek
----

find a maximum item of a max-heap, or a minimum item of a min-heap, respectively

push
----

returns the node of maximum value from a max heap [or minimum value from a min heap] after removing it from the heap

pop
---

removing the root node of a max heap [or min heap]

replace
-------

pop root and push a new key. More efficient than pop followed by push, since only need to balance once, not twice, and appropriate for fixed-size heaps

is-empty
--------

return true if the heap is empty, false otherwise

size
----

return the number of items in the heap

merge
-----

joining two heaps to form a valid new heap containing all the elements of both, preserving the original heaps

METHODS
=======

Constructor
-----------

BinaryHeap contains `Pair` objects and define order between `Pair.key` by the comparator. Comparator - is a `Code` which defines how to order elements internally. With help of the comparator you can create Min-heap or Max-heap.

  * empty constructor

        my $heap = Algorithm::Heap::Binary.new;

Default comparator is: `* <=> *`

  * named constructor

        my $heap = Algorithm::Heap::Binary.new(comparator => -> $a, $b {$b cmp $a});

  * constructor with heapify

        my @numbers = 1 .. *;
        my @letters = 'a' .. *;
        my @data = @numbers Z=> @letters;

        my $heap = Algorithm::Heap::Binary.new(comparator => * <=> *, |@data[^5]);

This will automatically heapify data for you.

clone
-----

Clones heap object for you with all internal data.

is-empty
--------

Returns `Bool` result as to empty Heap or not.

size
----

Returns `Int` which corresponds to amount elements in the Heap data structure.

push(Pair)
----------

Adds new Pair to the heap and resort it.

insert(Pair)
------------

Alias for push method.

peek
----

Returns `Pair` from the top of the Heap.

find-max
--------

Just an syntatic alias for peek method.

find-min
--------

Just an syntatic alias for peek method.

pop
---

Returns `Piar` from the top of the Heap and also removes it from the Heap.

delete-max
----------

Just an syntatic alias for pop method.

delete-min
----------

Just an syntatic alias for pop method.

replace(Pair)
-------------

Replace top element with another Pair. Returns replaced element as a result.

merge(Algorithm::Heap)
----------------------

Construct a new Heap merging current one and passed to as an argument.

Seq
---

Returns `Seq` of Heap elements. This will clone the data for you, so initial data structure going to be untouched.

Str
---

Prints internal representation of the Heap (as an `Array`).

iterator
--------

Method wich provides iterator (`role Iterable`). Will clone current Heap for you.

sift-up
-------

Internal method to make sift-up operation.

sift-down
---------

Internal method to make sift-down operation.

AUTHOR
======

[cono](mailto:q@cono.org.ua)

COPYRIGHT AND LICENSE
=====================

Copyright 2018 cono

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

LINKS
=====

  * [https://en.wikipedia.org/wiki/Heap_(data_structure)](https://en.wikipedia.org/wiki/Heap_(data_structure))

  * [https://en.wikipedia.org/wiki/Binary_heap](https://en.wikipedia.org/wiki/Binary_heap)

