[![Build Status](https://travis-ci.org/lizmat/P5fileno.svg?branch=master)](https://travis-ci.org/lizmat/P5fileno)

NAME
====

P5fileno - Implement Perl 5's fileno() built-in

SYNOPSIS
========

    use P5fileno;

    say fileno $*IN;    # 0
    say fileno $*OUT;   # 1
    say fileno $*ERR;   # 2
    say fileno $foo;    # something like 16

DESCRIPTION
===========

This module tries to mimic the behaviour of the `fileno` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

When calling with an unopened `IO::Handle`, this version will return `Nil`. That's the closest thing there is to `undef` in Perl 6.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5fileno . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

