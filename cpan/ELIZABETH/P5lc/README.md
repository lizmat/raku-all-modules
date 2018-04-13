[![Build Status](https://travis-ci.org/lizmat/P5lc.svg?branch=master)](https://travis-ci.org/lizmat/P5lc)

NAME
====

P5lc - Implement Perl 5's lc() / uc() built-ins

SYNOPSIS
========

    use P5lc;

    say lc "FOOBAR"; # foobar
    with "ZIPPO" {
        say lc();  # zippo, may need to use parens to avoid compilation error
    }

    say uc "foobar"; # FOOBAR
    with "zippo" {
        say uc();  # ZIPPO, may need to use parens to avoid compilation error
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `lc` / `uc` built-ins of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5lc . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

