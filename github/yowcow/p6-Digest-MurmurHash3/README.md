[![Build Status](https://travis-ci.org/yowcow/p6-Digest-MurmurHash3.svg?branch=master)](https://travis-ci.org/yowcow/p6-Digest-MurmurHash3)

NAME
====

Digest::MurmurHash3 - MurmurHash3 implementation for Perl 6

SYNOPSIS
========

    use Digest::MurmurHash3;

    my Int $uint32 = murmurhash3_32($key, $seed);

    my Buf $hex8   = murmurhash3_32_hex($key, $seed);

    my Int @uint32 = murmurhash3_128($key, $seed);

    my Buf $hex32  = murmurhash3_128_hex($key, $seed);

DESCRIPTION
===========

Digest::MurmurHash3 is a [MurmurHash3](https://github.com/aappleby/smhasher) hashing algorithm implementation.

METHODS
=======

murmurhash3_32(Str $key, uint32 $seed) returns Int
--------------------------------------------------

Calculates 32-bit hash, and returns as Int.

murmurhash3_32_hex(Str $key, uint32 $seed) returns Buf
------------------------------------------------------

Calculates 32-bit hash, and returns as Buf. A hex string can be obtained with `.unpack("H4")`.

murmurhash3_128(Str $key, uint32 $seed) returns Array[Int]
----------------------------------------------------------

Calculates 128-bit hash, and returns as Array[Int] with length of 4.

murmurhash3_128_hex(Str $key, uint32 $seed) returns Buf
-------------------------------------------------------

Calculates 128-bit hash, and returns as Buf. A hex string can be obtained with `.unpack("H16")`.

AUTHOR
======

yowcow <yowcow@cpan.org>

COPYRIGHT AND LICENSE
=====================

MurmurHash3 was written by [Austin Appleby](https://github.com/aappleby), and is released under MIT license.

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
