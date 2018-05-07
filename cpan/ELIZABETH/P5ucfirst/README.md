[![Build Status](https://travis-ci.org/lizmat/P5ucfirst.svg?branch=master)](https://travis-ci.org/lizmat/P5ucfirst)

NAME
====

P5ucfirst - Implement Perl 5's ucfirst() built-in [DEPRECATED]

SYNOPSIS
========

    use P5ucfirst;

    say ucfirst "foobar"; # Foobar

    with "zippo" {
        say ucfirst;  # Zippo
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `ucfirst` of Perl 5 as closely as possible. It has been deprecated in favour of the `P5lcfirst` module, which exports both `ucfirst` and `lcfirst`. Please use that module instead of this one.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ucfirst . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

