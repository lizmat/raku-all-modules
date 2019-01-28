NAME
====

Algorithm::SkewHeap - a mergable min heap

VERSION
=======

0.0.1

SYNOPSIS
========

    use Algorithm::SkewHeap;

    my $heap = Algorithm::SkewHeap.new;

    for (1 .. 1000).pick(1000) -> $n {
      $heap.put($n);
    }

    until $heap.is-empty {
      my $n = $heap.take;
    }

    $heap.merge($other-heap);

DESCRIPTION
===========

A skew heap is a type of heap based on a binary tree in which all operations are based on merging subtrees, making it possible to quickly combine multiple heaps, while still retaining speed and efficiency. Ammortized performance is O(log n) or better (see [https://en.wikipedia.org/wiki/Skew_heap](https://en.wikipedia.org/wiki/Skew_heap)).

SORTING
=======

Items in the heap are returned with the lowest first. Comparisons are done with the greater than operator, which may be overloaded as needed for types intended to be used in the heap.

class Algorithm::SkewHeap
-------------------------

SkewHeap class

### method size

```perl6
method size() returns Int
```

Returns the number of items in the heap

### method is-empty

```perl6
method is-empty() returns Bool
```

Returns true when the heap is empty

### method top

```perl6
method top() returns Any
```

Returns the top item in the heap without removing it.

### method take

```perl6
method take() returns Any
```

Removes and returns the top item in the heap.

### method put

```perl6
method put(
    $value
) returns Int
```

Adds a new item to the heap. Returns the new size of the heap.

### method merge

```perl6
method merge(
    Algorithm::SkewHeap $other
) returns Int
```

Destructively merges with another heap. The other heap should be considered unusable afterward. Returns the new size of the heap.

### method explain

```perl6
method explain() returns Nil
```

Prints the structure of the heap for debugging purposes.

