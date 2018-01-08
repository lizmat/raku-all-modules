[![Build Status](https://travis-ci.org/lizmat/Sub-Name.svg?branch=master)](https://travis-ci.org/lizmat/Sub-Name)

NAME
====

Sub::Name - Port of Perl 5's Sub::Name

SYNOPSIS
========

    use Sub::Name;

    subname $name, $callable;

    $callable = subname foo => { ... };

DESCRIPTION
===========

This module has only one function, which is also exported by default:

subname NAME, CALLABLE

Assigns a new name to referenced Callable. If package specification is omitted in the name, then the current package is used. The return value is the Callable.

The name is only used for informative routines. You won't be able to actually invoke the Callable by the given name. To allow that, you need to do assign it to a &-sigilled variable yourself.

Note that for anonymous closures (Callables that reference lexicals declared outside the Callable itself) you can name each instance of the closure differently, which can be very useful for debugging.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version originally developed by Matthijs van Duin.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

