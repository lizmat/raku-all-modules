[![Build Status](https://travis-ci.org/lizmat/Hash-LRU.svg?branch=master)](https://travis-ci.org/lizmat/Hash-LRU)

NAME
====

Hash::LRU - trait for limiting number of keys in hashes

SYNOPSIS
========

    use Hash::LRU;

    my %h is LRU;   # defaults to elements => 100

    my %h is LRU(elements => 42);

    my %h{Any} is LRU;  # object hashes also supported

DESCRIPTION
===========

Hash::LRU provides a `is LRU` trait on `Hash`es as an easy way to limit the number of keys kept in the `Hash`. Keys will be added as long as the number of keys is under the limit. As soon as a new key is added that would exceed the limit, the least recently used key is removed from the `Hash`.

Both "normal" as well as object hashes are supported.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-LRU . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

