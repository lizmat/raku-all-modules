[![Build Status](https://travis-ci.org/lizmat/Bits.svg?branch=master)](https://travis-ci.org/lizmat/Bits)

NAME
====

Bits - provide bit related functions

SYNOPSIS
========

    use Bits;  # exports "bit", "bits", "bitcnt"

    say bit(8, 3);    # 1000 -> True
    say bit(7, 3);    # 0111 -> False

    say bits(8);      # 1000 -> (3,).Seq
    say bits(7);      # 0111 -> (0,1,2).Seq

    say bitcnt(8);    # 1000 -> 1
    say bitcnt(7);    # 0111 -> 3

DESCRIPTION
===========

This module exports a number of function to handle bits in unsigned integer values.

SUBROUTINES
===========

bit
---

    sub bit(Int:D value, UInt:D bit --> Bool:D)

Takes a integer value and a bit number and returns whether that bit is set.

bits
----

    sub bits(Int:D value --> Seq:D)

Takes a integer value and returns a `Seq`uence of the bit numbers that are significant in the value. For negative values, these are the bits that are 0.

bitcnt
------

    sub bitcnt(Int:D value --> Int:D)

Takes a integer value and returns the number of significant bits that are set in the value. For negative values, this is the number of bits that are 0.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Bits . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

