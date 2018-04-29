[![Build Status](https://travis-ci.org/lizmat/P5shift.svg?branch=master)](https://travis-ci.org/lizmat/P5shift)

NAME
====

P5shift - Implement Perl 5's shift() / unshift() built-ins

SYNOPSIS
========

    use P5shift;

    say shift;  # shift from @*ARGS, if any

    sub a { dd @_; dd shift; dd @_ }; a 1,2,3;
    [1, 2, 3]
    1
    [2, 3]

    my @a = 1,2,3;
    say unshift @a, 42;  # 4

DESCRIPTION
===========

This module tries to mimic the behaviour of the `shift` and `unshift` functions of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5shift . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

