[![Build Status](https://travis-ci.org/samgwise/p6-Math-Curves.svg?branch=master)](https://travis-ci.org/samgwise/p6-Math-Curves)

NAME
====

Math::Curves - Simple functions for simple curves.

SYNOPSIS
========

    use Math::Curves;

    # find the point 1/3 along a linear bézier function.
    #   Transition, p0   p1
    bézier 1/3,     0,  40;

    # find the point 1/3 along a quadratic bézier function.
    #   Transition, p0  p1   p2
    bézier 1/3,     0,  40,  30;

    # find the point 1/3 along a cubic bézier function.
    #   Transition, p0  p1  p2   p4
    bézier 1/3,     0,  40, 30, -10.5;

    # find the point 1/3 along a bézier curve of any size > 1.
    #   Transition,  p0  p1  p2   ...
    bézier 1/3,     (0,  40, 30, -10.5,  18.28);

    # Calculate the length of a line with a given gradient
    #    position(x)  gradient
    line 2,           1/1;

DESCRIPTION
===========

Math::Curves provides some simple functions for plotting points on a curve. The methods above are the only functions currently implemented but I hope to see this list grow over time.

Contributing
============

This module is still quite incomplete so please contribute your favourite functions! To do so submit a pull request to the repo on github: https://github.com/samgwise/p6-Math-Curves

Contributors will be credited and appreciated :)

AUTHOR
======

    Sam Gillespie

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

