[![Build Status](https://travis-ci.org/lizmat/P5rand.svg?branch=master)](https://travis-ci.org/lizmat/P5rand)

NAME
====

P5rand - Implement Perl 5's rand() / srand() built-ins

SYNOPSIS
========

    use P5rand;

    say rand;    # a number between 0 and 1

    say rand 42; # a number between 0 and 42

    srand(666);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `rand` and `srand` built-ins of Perl 5 as closely as possible.

PORTING CAVEATS
===============

It is currently impossible to get the default `srand()` value, but this may change in a future version of Perl 6. Until that time, `srand()` will return `Nil` if `srand` was never called with a value before.

Currently, some Perl 6 grammar checks are a bit too overzealous with regards to calling `rand` with a parameter:

    say rand(42);   # Unsupported use of rand(N)

This overzealousness can be circumvented by prefixing the subroutine name with `&`:

    say &rand(42);  # 24.948543810572648

until we have a way to curb this overzealousness.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5rand . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

