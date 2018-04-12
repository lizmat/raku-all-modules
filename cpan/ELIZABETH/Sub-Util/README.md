[![Build Status](https://travis-ci.org/lizmat/Sub-Util.svg?branch=master)](https://travis-ci.org/lizmat/Sub-Util)

NAME
====

Sub::Util - Port of Perl 5's Sub::Util 1.49

SYNOPSIS
========

    use Sub::Util <subname set_subname>

DESCRIPTION
===========

`Sub::Util` contains a selection of subroutines that people have expressed would be nice to have in the perl core, but the usage would not really be high enough to warrant the use of a keyword, and the size would be so small that being individual extensions would be wasteful.

By default `Sub::Util` does not export any subroutines.

subname
-------

    my $name = subname( $callable );

Returns the name of the given Callable, if it has one. Normal named subs will give a fully-qualified name consisting of the package and the localname separated by `::`. Anonymous Callables will give `__ANON__` as the localname. If a name has been set using `set_subname`, this name will be returned instead.

*Users of Sub::Name beware*: This function is **not** the same as `Sub::Name::subname`; it returns the existing name of the sub rather than changing it. To set or change a name, see instead `set_subname`.

set_subname
-----------

    my $callable = set_subname $name, $callable;

Sets the name of the function given by the Callable. Returns the Callable itself. If the `$name` is unqualified, the package of the caller is used to qualify it.

This is useful for applying names to anonymous Callables so that stack traces and similar situations, to give a useful name rather than having the default. Note that this name is only used for this situation; the `set_subname` will not install it into the symbol table; you will have to do that yourself if required.

However, since the name is not used by perl except as the return value of `caller`, for stack traces or similar, there is no actual requirement that the name be syntactically valid as a perl function name. This could be used to attach extra information that could be useful in debugging stack traces.

This function was copied from `Sub::Name::subname` and renamed to the naming convention of this module.

FUNCTIONS NOT PORTED
====================

It did not make sense to port the following functions to Perl 6, as they pertain to specific Pumpkin Perl 5 internals.

    prototype set_prototype

Attempting to import these functions will result in a compilation error with hopefully targeted feedback. Attempt to call these functions using the fully qualified name (e.g. `Sub::Util::set_prototype($a)`) will result in a run time error with the same feedback.

SEE ALSO
========

[Sub::Name](Sub::Name)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sub-Util . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version originally developed by Paul Evans.

