[![Build Status](https://travis-ci.org/lizmat/Sub-Memoized.svg?branch=master)](https://travis-ci.org/lizmat/Sub-Memoized)

NAME
====

Sub::Memoized - trait for memoizing calls to subroutines

SYNOPSIS
========

    use Sub::Memoized;

    sub a($a,$b) is memoized {
        # do some expensive calculation
    }

    sub b($a, $b) is memoized( my %cache ) {
        # do some expensive calculation with direct access to cache
    }

    use Hash::LRU;
    sub c($a, $b) is memoized( my %cache is LRU( elements => 2048 ) ) {
        # do some expensive calculation, keep last 2048 results returned
    }

DESCRIPTION
===========

Sub::Memoized provides a `is memoized` trait on `Sub`routines as an easy way to cache calculations made by that subroutine (assuming a given set of input parameters will always produce the same result).

Optionally, you can specify a hash that will serve as the cache. This allows later access to the generated results. Or you can specify a specially crafted hash, such as one made with `Hash::LRU`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sub-Memoized . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

