[![Build Status](https://travis-ci.org/lizmat/P5built-ins.svg?branch=master)](https://travis-ci.org/lizmat/P5built-ins)

NAME
====

P5built-ins - Implement Perl 5's built-in functions

SYNOPSIS
========

    use P5functions;   # import all P5 built-in functions supported

    use P5functions <tie untie>;  # only import specific ones

    tie my @a, Foo;

DESCRIPTION
===========

This module provides an easy way to import a growing number of built-in functions of Perl 5 in Perl 6. Currently supported at:

    caller chomp chop chr each hex index lcfirst length oct ord pack quotemeta
    ref rindex substr tie tied times ucfirst unpack untie

PORTING CAVEATS
===============

Please look at the porting caveats of the underlying modules that actually provide the functionality:

    module      | built-in functions
    ------------+-------------------
    P5caller    | caller
    P5each      | each
    P5length    | length
    P5pack      | pack unpack
    P5ref       | ref
    P5tie       | tie, tied, untie
    P5times     | times

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5built-ins . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

