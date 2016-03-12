[![Build Status](https://travis-ci.org/okaoka/p6-Algorithm-TernarySearchTree.svg?branch=master)](https://travis-ci.org/okaoka/p6-Algorithm-TernarySearchTree)

NAME
====

Algorithm::TernarySearchTree - the algorithm which blends trie and binary search tree

SYNOPSIS
========

    use Algorithm::TernarySearchTree;

    my $tst = Algorithm::TernarySearchTree.new();

    $tst.insert("Perl6 is fun");
    $tst.insert("Perl5 is fun");

    my $false-flag = $tst.contains("Kotlin is fun"); # False
    my $true-flag = $tst.contains("Perl6 is fun"); # True

    my $matched = $tst.partial-match("Perl. is fun"); # set("Perl5 is fun","Perl6 is fun")
    my $not-matched = $tst.partial-match("...lin is fun"); # set()

DESCRIPTION
===========

Algorithm::TernarySearchTree is a implementation of the ternary search tree. Ternary search tree is the algorithm which blends trie and binary search tree.

CONSTRUCTOR
-----------

### new

    my $tst = Algorithm::TernarySearchTree.new();

METHODS
-------

### insert(Str $key)

    $tst.insert($key);

Inserts the key to the tree.

### contains(Str $key) returns Bool:D

    my $flag = $tst.contains($key);

Returns whether given key exists in the tree.

### partial-match(Str $fuzzy-key) returns Set:D

    my Set $matched = $tst.partial-match($fuzzy-key);

Searches partially matched keys in the tree. If you want to match any character except record separator(hex: 0x1e), you can use dot symbol. For example, the query "Perl." matches "Perla", "Perl5", "Perl6", and so on.

METHODS NOT YET IMPLEMENTED
---------------------------

near-search, traverse, and so on.

AUTHOR
======

okaoka <cookbook_000@yahoo.co.jp>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Bentley, Jon L., and Robert Sedgewick. "Fast algorithms for sorting and searching strings." SODA. Vol. 97. 1997.
