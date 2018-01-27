[![Build Status](https://travis-ci.org/lizmat/P5fc.svg?branch=master)](https://travis-ci.org/lizmat/P5fc)

NAME
====

P5fc - Implement Perl 5's fc() built-in

SYNOPSIS
========

    use P5fc;

    say fc("FOOBAR") eq fc("FooBar"); # true

    with "ZIPPO" {
        say fc();  # zippo, may need to use parens to avoid compilation error
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `fc` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5fc . Comments and Pull Requests are wefcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

