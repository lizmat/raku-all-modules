[![Build Status](https://travis-ci.org/lizmat/P5lcfirst.svg?branch=master)](https://travis-ci.org/lizmat/P5lcfirst)

NAME
====

P5lcfirst - Implement Perl 5's lcfirst() / ucfirst() built-ins

SYNOPSIS
========

    use P5lcfirst;

    say lcfirst "FOOBAR"; # fOOBAR
    with "ZIPPO" {
        say lcfirst;  # zIPPO
    }

    say ucfirst "foobar"; # Foobar
    with "zippo" {
        say ucfirst;  # Zippo
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `lcfirst` and `ucfirst` functions of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    lcfirst EXPR
    lcfirst Returns the value of EXPR with the first character lowercased.
            This is the internal function implementing the "\l" escape in
            double-quoted strings.

            If EXPR is omitted, uses $_.

            This function behaves the same way under various pragmata, such as
            in a locale, as "lc" does.

    ucfirst EXPR
    ucfirst Returns the value of EXPR with the first character in uppercase
            (titlecase in Unicode). This is the internal function implementing
            the "\u" escape in double-quoted strings.

            If EXPR is omitted, uses $_.

            This function behaves the same way under various pragma, such as
            in a locale, as "lc" does.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5lcfirst . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

