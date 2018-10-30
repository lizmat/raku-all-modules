[![Build Status](https://travis-ci.org/zengargoyle/p6-Algorithm-Trie-libdatrie.svg?branch=master)](https://travis-ci.org/zengargoyle/p6-Algorithm-Trie-libdatrie)

NAME
====

Algorithm::Trie::libdatrie - a character keyed trie using the datrie library.

SYNOPSIS
========

    use Algorithm::Trie::libdatrie;

    my Trie $t .= new: 'a'..'z', 'A'..'Z';
    my @words = <pool prize preview prepare produce progress>;
    for @words.kv -> $data, $word {
      $t.store( $word, $data );
    }
    $data = $t.retrieve($word);
    my $iter = $t.iterator;
    while $iter.next {
      $key = $iter.key;
      $data = $iter.value;
    }

WARNING
=======

More documentation and maybe a few more features and tests are planned. For now the tests are probably the best documentation.

DESCRIPTION
===========

Algorithm::Trie::libdatrie is an implementation of a character keyed [trie](http://en.wikipedia.org/wiki/Trie) using the [datrie](http://linux.thai.net/~thep/datrie/datrie.html) library.

As the author of the datrie library states:

Trie is a kind of digital search tree, an efficient indexing method with O(1) time complexity for searching. Comparably as efficient as hashing, trie also provides flexibility on incremental matching and key spelling manipulation. This makes it ideal for lexical analyzers, as well as spelling dictionaries. This library is an implementation of double-array structure for representing trie, as proposed by Junichi Aoe. The details of the implementation can be found at [http://linux.thai.net/~thep/datrie/datrie.html](http://linux.thai.net/~thep/datrie/datrie.html)

Classes and Methods
===================

Trie
----

    multi method new(**@ranges) returns Trie
    multi method new(Str $file) returns Trie
    method save(Str $file) returns Bool
    method is-dirty() returns Bool
    method store(Str $key, Int $data) returns Bool
    method store-if-absent(Str $key, Int $data) returns Bool
    method retrieve(Str $key) returns Int
    method delete(Str $key) returns Bool
    method root() returns TrieState
    method iterator() returns TrieIterator
    method free()
    /* NYI
    sub enum_func(Str $key, Int $value, Pointer[void] $stash) returns Bool { * }
    method enumerate(&enum_func, Pointer[void] $stash) returns Bool
    */

  * new

    my Trie $t .= new: 'a'..'z', 'A'..'Z', '0'..'9';

The set of characters used in `key`s has a maximum size of 255. The characters themselves may be any unicode character who's code will fit in a 32 bit uint. The `new` function will map the input ranges into `0..254` internally.

    my Trie $t .= new: $file;

A Trie may be loaded from a <var>$file</var> created by the `save` method.

  * root, iterator

These methods return objects of class `TrieState` and `TrieIterator` that are positioned at the root of the Trie.

  * the rest

Should be mostly self-explanatory. See the tests.

TrieState
---------

A TrieState object is used to walk through the Trie character by character. A TrieState object may also be used to create a TrieIterator in order to iterate over the nodes beneath the TrieStat's current position.

    method clone() returns TrieState
    method rewind()
    method walk(Str $c where *.chars == 1) returns Bool
    method is-walkable(Str $c where *.chars == 1) returns Bool
    method walkable-chars() returns Array[Str]
    method is-terminal() returns Bool
    method is-single() returns Bool
    method is-leaf() returns Bool
    method value() returns Int
    method free()

TrieIterator
------------

A TrieIterator can be created from the Trie directly via `$trie.iterator` or from a TrieState via `TrieIterator.new($trie-state)`.

    method new(TrieState $state) returns TrieIterator
    method next() returns Bool
    method key() returns Str
    method value() returns Int
    method free()

SEE ALSO
========

The datrie library: [http://linux.thai.net/~thep/datrie/datrie.html](http://linux.thai.net/~thep/datrie/datrie.html)

Wikipedia entry for: [Trie](http://en.wikipedia.org/wiki/Trie)

AUTHOR
======

zengargoyle <zengargoyle@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 zengargoyle

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
