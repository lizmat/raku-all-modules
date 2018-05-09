[![Build Status](https://travis-ci.org/Scimon/p6-Algorithm-GooglePolylineEncoding.svg?branch=master)](https://travis-ci.org/Scimon/p6-Algorithm-GooglePolylineEncoding)

NAME
====

Algorithm::GooglePolylineEncoding - Encode and Decode lat/lon polygons using Google Maps string encoding.

SYNOPSIS
========

    use Algorithm::GooglePolylineEncoding;
    my $encoded = encode-polyline( { :lat(90), :lon(90) }, { :lat(0), :lon(0) }, { :lat(22.5678), :lon(45.2394) } );
    my @polyline = deocde-polyline( $encoded );

DESCRIPTION
===========

Algorithm::GooglePolylineEncoding is intended to be used to encoded and decode Google Map polylines.

Note this is a lossy encoded, any decimal values beyond the 5th place in a latitude of longitude will be lost.

USAGE
-----

### encode-polyline( { :lat(Real), :lon(Real) }, ... ) --> Str

### encode-polyline( [ { :lat(Real), :lon(Real) }, ... ] ) --> Str

### encode-polyline( Real, Real, ... ) --> Str

Encodes a polyline list (supplied in any of the listed formats) and returns a Str of the encoded data.

### decode-polyline( Str ) --> [ { :lat(Real), :lon(Real) }, ... ]

Takes a string encoded using the algorithm and returns an Array of Hashes with lat / lon keys.

For further details on the encoding algorithm please see the follow link:

https://developers.google.com/maps/documentation/utilities/polylinealgorithm

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
