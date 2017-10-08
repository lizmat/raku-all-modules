[![Build Status](https://travis-ci.org/titsuki/p6-Geo-Hash.svg?branch=master)](https://travis-ci.org/titsuki/p6-Geo-Hash)

NAME
====

Geo::Hash - A Perl 6 bindings for libgeohash

SYNOPSIS
========

    use Geo::Hash;

    my $hash = geo-encode(42.60498046875e0, -5.60302734375e0, 5);
    say $hash; # OUTPUT: «ezs42»
    my Geo::Hash::Coord $coord = geo-decode($hash);
    say $coord.latitude; # OUTPUT: «42.60498046875e0»
    say geo-neighbors($hash); # OUTPUT: «[ezs48 ezs49 ezs43 ezs41 ezs40 ezefp ezefr ezefx]»

DESCRIPTION
===========

Geo::Hash is a Perl 6 bindings for libgeohash.

SUBS
----

### geo-encode

Defined as:

    sub geo-encode(Num $lat, Num $lng, Int $precision --> Str) is export(:MANDATORY)

Encodes given `$lat` and `$lng` pair with precision of `$precision` and creates a hash value.

### geo-decode

Defined as:

    sub geo-decode(Str $hash --> Geo::Hash::Coord) is export(:MANDATORY)

Decodes given `$hash` and creates a `Geo::Hash::Coord` object.

### geo-neighbors

Defined as:

    sub geo-neighbors(Str $hash --> List) is export(:MANDATORY)

Returns the 8-neighboring positions, where each position is represented as hash code.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 titsuki

libgeohash ( https://github.com/simplegeo/libgeohash ) by Derek Smith is licensed under the BSD-3-Clause License.

This library is free software; you can redistribute it and/or modify it under the BSD-3-Clause License.
