[![Build Status](https://travis-ci.org/lizmat/P5built-ins.svg?branch=master)](https://travis-ci.org/lizmat/P5built-ins)

NAME
====

P5built-ins - Implement Perl 5's built-in functions

SYNOPSIS
========

    use P5built-ins;   # import all P5 built-in functions supported

    use P5built-ins <tie untie>;  # only import specific ones

    tie my @a, Foo;

DESCRIPTION
===========

This module provides an easy way to import a growing number of built-in functions of Perl 5 in Perl 6. Currently supported at:

    caller chdir chomp chop chr each fc fileno hex index lc lcfirst length
    oct ord pack pop push quotemeta readlink ref rindex seek sleep study
    substr tie tied times uc ucfirst unpack untie

The following file test operators are also available:

    -r -w -x -e -f -d -s -z -l

PORTING CAVEATS
===============

Please look at the porting caveats of the underlying modules that actually provide the functionality:

    module      | built-in functions
    ------------+-------------------
    P5caller    | caller
    P5chdir     | chdir
    P5each      | each
    P5fileno    | fileno
    P5length    | length
    P5pack      | pack unpack
    P5readlink  | readlink
    P5ref       | ref
    P5reverse   | reverse
    P5study     | study
    P5tie       | tie, tied, untie
    P5times     | times
    P5-X        | -r -w -x -e -f -d -s -z -l

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5built-ins . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

