[![Build Status](https://travis-ci.org/lizmat/Hash-with.svg?branch=master)](https://travis-ci.org/lizmat/Hash-with)

NAME
====

Hash-with - Roles for automatically mapping keys in hashes

SYNOPSIS
========

    use Hash-with;

    my %h1 does Hash-lc = A => 42;             # map all keys to lowercase
    say %h1<a>;    # 42

    my %h2 does Hash-uc = a => 42;             # map all keys to uppercase
    say %h2<A>;    # 42

    sub ordered($a) { $a.comb.sort.join }
    my %h3 does Hash-with[&ordered] = oof => 42;  # sort characters of key
    say %h3<foo>;  # 42

DESCRIPTION
===========

Hash::with provides several `role`s that can be mixed in with a `Hash`.

Hash-lc
-------

The role that will convert all keys of a hash to their **lowercase** equivalent before being used to access the hash.

    my %h1 does Hash-lc = A => 42;             # map all keys to lowercase
    say %h1<a>;    # 42

This is in fact an optimized version of `does Hash-with[&lc]`.

Hash-uc
-------

The role that will convert all keys of a hash to their **uppercase** equivalent before being used to access the hash.

    my %h2 does Hash-uc = a => 42;             # map all keys to uppercase
    say %h2<A>;    # 42

This is in fact an optimized version of `does Hash-with[&uc]`.

Hash-with
---------

The role that will convert all keys of a hash according to a `mapper` function before being used to access the hash.

    sub ordered($a) { $a.comb.sort.join }
    my %h3 does Hash-with[&ordered] = oof => 42;  # order all keys
    say %h3<foo>;  # 42

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-with . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

