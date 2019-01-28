[![Build Status](https://travis-ci.org/lizmat/P5rand.svg?branch=master)](https://travis-ci.org/lizmat/P5rand)

NAME
====

P5rand - Implement Perl 5's rand() built-ins [DEPRECATED]

SYNOPSIS
========

    use P5rand;

    say rand;    # a number between 0 and 1

    say rand 42; # a number between 0 and 42

DESCRIPTION
===========

This module tries to mimic the behaviour of the `rand` built-in of Perl 5 as closely as possible. It has been deprecated in favour of the `P5math` module, which exports `rand` among many other math related functions. Please use that module instead of this one.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5rand . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

