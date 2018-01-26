[![Build Status](https://travis-ci.org/lizmat/P5quotemeta.svg?branch=master)](https://travis-ci.org/lizmat/P5quotemeta)

NAME
====

P5quotemeta - Implement Perl 5's quotemeta() built-in

SYNOPSIS
========

    use P5quotemeta; # exports quotemeta()

    my $a = "abc";
    say quotemeta $a;

    $_ = "abc";
    say quotemeta;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `quotemeta` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5quotemeta . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Stolen from Zoffix Znet's unpublished String::Quotemeta, as found at:

    https://github.com/zoffixznet/perl6-String-Quotemeta

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

