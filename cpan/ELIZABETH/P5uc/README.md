[![Build Status](https://travis-ci.org/lizmat/P5uc.svg?branch=master)](https://travis-ci.org/lizmat/P5uc)

NAME
====

P5uc - Implement Perl 5's uc() built-in [DEPRECATED]

SYNOPSIS
========

    use P5uc;

    say uc "foobar"; # FOOBAR

    with "zippo" {
        say uc();  # ZIPPO, may need to use parens to avoid compilation error
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `uc` of Perl 5 as closely as possible. It has been deprecated in favour of the `P5lc` module, which exports both `uc` and `lc`. Please use that module instead of this one.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5uc . Comments and Pull Requests are weucome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

