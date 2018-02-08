[![Build Status](https://travis-ci.org/samgwise/p6-ScaleVec.svg?branch=master)](https://travis-ci.org/samgwise/p6-ScaleVec)

NAME
====

ScaleVec - A flexible yet accurate music representation system.

SYNOPSIS
========

    use ScaleVec;

    my ScaleVec $major-scale .= new( :vector(0, 2, 4, 5, 7, 9, 11, 12) );

    # Midi notes 0 - 127 with our origin on middle C (for most midi specs)
    use ScaleVec::Scale::Fence;
    my ScaleVec::Scale::Fence $midi .= new(
      :vector(60, 61)
      :repeat-interval(12)
      :lower-limit(0)
      :upper-limit(127)
    );

    # A two octave C major scale in midi note values
    say do for -7..7 {
      $midi.step: $major-scale.step($_)
    }

DESCRIPTION
===========

Encapsulating the power of linear algebra in an easy to use music library, ScaleVec provides a way to represent musical structures such as chords, rhythms, scales and tempos with a common format.

CONTRIBUTIONS
=============

To contribute, head to the github page: https://github.com/samgwise/p6-ScaleVec

AUTHOR
======

    Sam Gillespie

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

