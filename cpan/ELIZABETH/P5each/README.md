[![Build Status](https://travis-ci.org/lizmat/P5each.svg?branch=master)](https://travis-ci.org/lizmat/P5each)

NAME
====

P5each - Implement Perl 5's each() built-in

SYNOPSIS
========

    use P5each;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `each` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Using list assignments in `while` loops will not work, because the assignment will happen anyway even if an empty list is returned, so that this:

    while (($key, $value) = each %hash) { }

will loop forever. There is unfortunately no way to fix this in Perl 6 module space at the moment. But a slightly different syntax, will work as expected:

    while each(%hash) -> ($key,$value) { }

Also, this will alias the values in the list, so you don't actually need to define `$key` and `$value` outside of the `while` loop to make this work.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5each . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

