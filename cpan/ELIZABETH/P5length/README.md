[![Build Status](https://travis-ci.org/lizmat/P5length.svg?branch=master)](https://travis-ci.org/lizmat/P5length)

NAME
====

P5length - Implement Perl 5's length() built-in

SYNOPSIS
========

    use P5length; # exports length()

    say length("foobar"); # 6
    say length(Str);      # Str

    $_ = "foobar";
    say length;           # 6

DESCRIPTION
===========

This module tries to mimic the behaviour of the `length` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Since the Perl 5 documentation mentions `characters` rather than codepoints, `length` will return the number of characters, as seen using Normalization Form Grapheme (NFG).

`length` in Perl 5 is supposed to return `undef` when given `undef`. Since undefined values are type objects in Perl 6, and it looks like `length` is simply returning what it was given in the undefined case, it felt appropriate to simply return the given type object rather than `Nil`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5length . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

