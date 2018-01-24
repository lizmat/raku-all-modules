[![Build Status](https://travis-ci.org/lizmat/P5lcfirst.svg?branch=master)](https://travis-ci.org/lizmat/P5lcfirst)

NAME
====

P5lcfirst - Implement Perl 5's lcfirst() built-in

SYNOPSIS
========

    use P5lcfirst;

    say lcfirst "FOOBAR"; # fOOBAR

    with "ZIPPO" {
        say lcfirst;  # zIPPO
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `lcfirst` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5lcfirst . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

