[![Build Status](https://travis-ci.org/lizmat/Scalar-Util.svg?branch=master)](https://travis-ci.org/lizmat/Scalar-Util)

NAME
====

Scalar::Util - Port of Perl 5's Scalar::Util 1.49

SYNOPSIS
========

    use Scalar::Util <blessed dualvar isdual readonly refaddr reftype
                      isvstring looks_like_number>

DESCRIPTION
===========

`Scalar::Util` contains a selection of subroutines that people have expressed would be nice to have in the perl core, but the usage would not really be high enough to warrant the use of a keyword, and the size would be so small that being individual extensions would be wasteful.

By default `Scalar::Util` does not export any subroutines.

blessed
-------

    my $class = blessed( $object );

Returns the name of the class of the object.

refaddr
-------

    my $addr = refaddr( $object );

Returns the internal memory address of the object as a plain integer. Please note that Perl 6 implementations do **not** require the memory address of an object to be constant: in fact, with `MoarVM` as a back end, any longer living object **will** have its memory address changed over its lifetime.

reftype
-------

    my $type = reftype( $object );

For objects performing the `Positional` role, `ARRAY` will be returned. For objects performing the `Associative` role, `HASH` will be returned. Otherwise `Nil` will be returned.

dualvar
-------

    my $var = dualvar( $num, $string );

Returns a scalar that has the value `$num` when used as a number and the value `$string` when used as a string.

    $foo = dualvar 10, "Hello";
    $num = $foo + 2;                    # 12
    $str = $foo . " world";             # Hello world

isdual
------

    my $dual = isdual( $var );

If `$var` is a scalar that has both numeric and string values, the result is true.

    $foo = dualvar 86, "Nix";
    $dual = isdual($foo);               # True

isvstring
---------

    my $vstring = isvstring( $var );

Returns whether `$var` is a `Version` object.

    $vs    = v49.46.48;
    $isver = isvstring($vs);            # True

looks_like_number
-----------------

    my $isnum = looks_like_number( $var );

Returns true if `$var` can be coerced to a number.

readonly
--------

    my $ro = readonly( $var );

Returns true if `$var` is readonly (aka does not have a container).

    sub foo(\value) { readonly(value) }

    $readonly = foo($bar);              # False
    $readonly = foo(0);                 # True

FUNCTIONS NOT PORTED
====================

It did not make sense to port the following functions to Perl 6, as they pertain to specific Pumpkin Perl 5 internals.

    weaken isweak unweaken openhandle set_prototype tainted

Attempting to import these functions will result in a compilation error with hopefully targeted feedback. Attempt to call these functions using the fully qualified name (e.g. `Scalar::Util::weaken($a)`) will result in a run time error with the same feedback.

SEE ALSO
========

[List::Util](List::Util)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Scalar-Util . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version originally developed by Graham Barr, subsequently maintained by Matthijs van Duin, cPanel and Paul Evans.

