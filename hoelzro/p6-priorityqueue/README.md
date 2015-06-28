NAME
====

PriorityQueue

VERSION
=======

0.01

SYNOPSIS
========

```perl6
    use PriorityQueue;

    my $p = PriorityQueue.new;

    for 1 .. 100 {
        $p.push: 100.rand.floor;
    }

    # should return in increasing order
    while $p.shift -> $e {
        say $e;
    }

    # if you want a max heap, or just a different ordering:
    $p = PriorityQueue.new(:cmp(&infix:«>=»));
```

DESCRIPTION
===========

This class implements a priority queue data structure.

AUTHOR
======

Rob Hoelz <rob AT-SIGN hoelz.ro>
