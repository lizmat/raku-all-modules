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

This module tries to mimic the behaviour of the `reset` function of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    reset EXPR
    reset   Generally used in a "continue" block at the end of a loop to clear
            variables and reset "??" searches so that they work again. The
            expression is interpreted as a list of single characters (hyphens
            allowed for ranges). All variables and arrays beginning with one
            of those letters are reset to their pristine state. If the
            expression is omitted, one-match searches ("?pattern?") are reset
            to match again. Only resets variables or searches in the current
            package. Always returns 1. Examples:

                reset 'X';      # reset all X variables
                reset 'a-z';    # reset lower case variables
                reset;          # just reset ?one-time? searches

            Resetting "A-Z" is not recommended because you'll wipe out your
            @ARGV and @INC arrays and your %ENV hash. Resets only package
            variables; lexical variables are unaffected, but they clean
            themselves up on scope exit anyway, so you'll probably want to use
            them instead. See "my".

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

