[![Build Status](https://travis-ci.org/lizmat/P5__FILE__.svg?branch=master)](https://travis-ci.org/lizmat/P5__FILE__)

NAME
====

P5__FILE__ - Implement Perl 5's __FILE__ and associated functionality

SYNOPSIS
========

    use P5__FILE__;  # exports __FILE__, __LINE__, __PACKAGE__, __SUB__

DESCRIPTION
===========

This module tries to mimic the behaviour of `__FILE__`, `__LINE__`, `__PACKAGE__` and `__SUB__` in Perl 5 as closely as possible.

TERMS
=====

__PACKAGE__
-----------

A special token that returns the name of the package in which it occurs.

### Perl 6 

    $?PACKAGE.^name

Because `$?PACKAGE` gives you the actual `Package` object (which can be used for introspection), you need to call the `.^name` method to get a string with the name of the package.

__FILE__
--------

A special token that returns the name of the file in which it occurs.

### Perl 6 

    $?FILE

__LINE__
--------

A special token that compiles to the current line number.

### Perl 6 

    $?LINE

__SUB__
-------

A special token that returns a reference to the current subroutine, or "undef" outside of a subroutine.

### Perl 6

    &?ROUTINE

Because `&?ROUTINE` gives you the actual `Routine` object (which can be used for introspection), you need to call the `.name` method to get a string with the name of the subroutine.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5__FILE__ . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

