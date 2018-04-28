[![Build Status](https://travis-ci.org/lizmat/P5seek.svg?branch=master)](https://travis-ci.org/lizmat/P5seek)

NAME
====

P5seek - Implement Perl 5's seek() built-in

SYNOPSIS
========

    use P5seek;

    seek($filehandle, 42, 0);

    seek($filehandle, 42, SEEK_SET); # same, SEEK_CUR / SEEK_END also available

DESCRIPTION
===========

This module tries to mimic the behaviour of the `seek` function of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5seek . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

