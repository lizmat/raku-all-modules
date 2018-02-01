[![Build Status](https://travis-ci.org/lizmat/P5reverse.svg?branch=master)](https://travis-ci.org/lizmat/P5reverse)

NAME
====

P5reverse - Implement Perl 5's reverse() built-in

SYNOPSIS
========

    use P5reverse;

    say reverse "Foo";  # ooF

    with "Zippo" {
        say reverse();  # oppiZ, may need to use parens to avoid compilation error
    }

    say reverse 1,2,3;  # (3 2 1)

    with 1,2,3 {
        say reverse();  # (3 2 1), may need to use parens to avoid compilation error
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `reverse` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Whereas in Perl 5 the type of context determines how `reverse` operates, in this implementation it's the type of parameter that determines the semantics. When given a `List`, it will revert the order of the elements. When given something that can coerce to a `Str`, it will return a string with the characters reversed in order.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5reverse . Comments and Pull Requests are wereverseome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

