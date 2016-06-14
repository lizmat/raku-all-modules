[![Build Status](https://travis-ci.org/yowcow/p6-Algorithm-BloomFilter.svg?branch=master)](https://travis-ci.org/yowcow/p6-Algorithm-BloomFilter)

NAME
====

Algorithm::BloomFilter - A bloom filter implementation in Perl 6

SYNOPSIS
========

    use Algorithm::BloomFilter;

    my $filter = Algorithm::BloomFilter.new(
      capacity   => 100,
      error-rate => 0.01,
    );

    $filter.add("foo-bar");

    $filter.check("foo-bar"); # True

    $filter.check("bar-foo"); # False with possible false-positive

DESCRIPTION
===========

Algorithm::BloomFilter is a pure Perl 6 implementation of [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter), mostly based on [Bloom::Filter](https://metacpan.org/pod/Bloom::Filter) from Perl 5.

Digest::MurmurHash3 is used for hashing from version 0.1.0.

METHODS
=======

### new(Rat:D :$error-rate, Int:D :$capacity)

Creates a Bloom::Filter instance.

### add(Cool:D $key)

Adds a given key to filter instance.

### check(Cool:D $key) returns Bool

Checks if a given key is in filter instance.

INTERNAL METHODS
================

### calculate-shortest-filter-length(Int:D :$num-keys, Rat:D $error-rate) returns Hash[Int]

Calculates and returns filter's length and a number of hash functions.

### create-salts(Int:D :$count) returns Seq[Int]

Creates and returns `$count` unique and random uint32 salts.

### get-cells(Cool:D $key, Int:D :$filter-length, Int:D :$blankvec, Int:D :@salts) returns List

Calculates and returns positions to check in a bit vector.

SEE ALSO
========

[Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter)

[Bloom::Filter](https://metacpan.org/pod/Bloom::Filter)

AUTHOR
======

yowcow <yowcow@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
