[![Build Status](https://travis-ci.org/lizmat/P5ref.svg?branch=master)](https://travis-ci.org/lizmat/P5ref)

NAME
====

P5ref - Implement Perl 5's ref() built-in

SYNOPSIS
========

    use P5ref; # exports ref()

    my @a;
    say ref @a;  # ARRAY

    my %h;
    say ref %h;  # HASH

    my $a = 42;
    say ref $a;  # SCALAR

    sub &a { };
    say ref &a;  # CODE

    my $r = /foo/;
    say ref $r;  # Regexp

    my $v = v6.c;
    say ref $v;  # VSTRING

    my $i = 42;
    say ref $i;  # SCALAR

    my $j := 42;
    say ref $j;  # Int

DESCRIPTION
===========

This module tries to mimic the behaviour of the `ref` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Types not supported
-------------------

The following strings are currently never returned by `ref` because they have no sensible equivalent in Perl 6: `REF`, `GLOB`, `LVALUE`, `FORMAT`, `IO`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ref . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

