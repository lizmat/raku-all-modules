[![Build Status](https://travis-ci.org/lizmat/P5caller.svg?branch=master)](https://travis-ci.org/lizmat/P5caller)

NAME
====

P5caller - Implement Perl 5's caller() built-in

SYNOPSIS
========

    use P5caller;

    sub foo { bar }
    sub bar { say caller[3] } # foo

DESCRIPTION
===========

This module tries to mimic the behaviour of the `caller` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

In Perl 5, `caller` can return an 11 element list. In the Perl 6 implementation only the first 4 elements are the same as in Perl 5: package, filename, line, subname. The fifth element is actually the `Sub` or `Method` object and as such provides further introspection possibilities not found in Perl 5.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5caller . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

