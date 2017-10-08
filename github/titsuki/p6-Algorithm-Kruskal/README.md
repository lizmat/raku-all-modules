[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-Kruskal.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-Kruskal)

NAME
====

Algorithm::Kruskal - a perl6 implementation of Kruskal's Algorithm for constructing a spanning subtree of minimum length

SYNOPSIS
========

    use Algorithm::Kruskal;

    my $kruskal = Algorithm::Kruskal.new(vertex-size => 4);

    $kruskal.add-edge(0, 1, 2);
    $kruskal.add-edge(1, 2, 1);
    $kruskal.add-edge(2, 3, 1);
    $kruskal.add-edge(3, 0, 1);
    $kruskal.add-edge(0, 2, 3);
    $kruskal.add-edge(1, 3, 5);

    my %forest = $kruskal.compute-minimal-spanning-tree();
    %forest<weight>.say; # 3
    %forest<edges>.say; # [[1 2] [2 3] [3 0]]

DESCRIPTION
===========

Algorithm::Kruskal is a perl6 implementation of Kruskal's Algorithm for constructing a spanning subtree of minimum length

CONSTRUCTOR
-----------

    my $kruskal = Algorithm::Kruskal.new(%options);

### OPTIONS

  * `vertex-size => $vertex-size`

Sets vertex size. The vertices are numbered from `0` to `$vertex-size - 1`.

METHODS
-------

### add-edge(Int $from, Int $to, Real $weight)

    $kruskal.add-edge($from, $to, $weight);

Adds a edge to the graph. `$weight` is the weight between vertex `$from` and vertex `$to`.

### compute-minimal-spanning-tree() returns List

    my %forest = $kruskal.compute-minimal-spanning-tree();
    %forest<edges>.say; # display edges
    %forest<weight>.say; # display weight

Computes and returns a minimal spanning tree and its weight.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Kruskal, Joseph B. "On the shortest spanning subtree of a graph and the traveling salesman problem." Proceedings of the American Mathematical society 7.1 (1956): 48-50.
