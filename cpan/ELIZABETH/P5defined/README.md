[![Build Status](https://travis-ci.org/lizmat/P5defined.svg?branch=master)](https://travis-ci.org/lizmat/P5defined)

NAME
====

P5defined - Implement Perl 5's defined() / undef() built-ins

SYNOPSIS
========

    use P5defined;

    my $foo = 42;
    given $foo {
        say defined();  # True
    }

    say defined($foo);  # True

    $foo = undef();
    undef($foo);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `defined` and `undef` built-ins of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Because of some overzealous checks for Perl 5isms, it is necessary to put parentheses when using `undef` as a value. This may change at some point in the future.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5defined . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

