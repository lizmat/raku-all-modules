[![Build Status](https://travis-ci.org/lizmat/P5reset.svg?branch=master)](https://travis-ci.org/lizmat/P5reset)

NAME
====

P5reset - Implement Perl 5's reset() built-in

SYNOPSIS
========

    use P5reset;

    reset("a");   # reset all "our" variables starting with "a"

    reset("a-z"); # reset all "our" variables starting with lowercase letter

    reset;        # does not reset any variables

DESCRIPTION
===========

This module tries to mimic the behaviour of the `reset` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Since Perl 6 doesn't have the concept of `?one time searches?`, the no-argument form of `reset` will not reset any variables at all.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5reset . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

