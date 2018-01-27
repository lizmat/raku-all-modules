[![Build Status](https://travis-ci.org/lizmat/P5substr.svg?branch=master)](https://travis-ci.org/lizmat/P5substr)

NAME
====

P5substr - Implement Perl 5's substr() built-in

SYNOPSIS
========

    use P5substr; # exports substr()

    say substr("foobar",3);   # bar
    say substr("foobar",1,4); # ooba

    my $a = "foobar";
    substr($a,1,2) = "OO";
    say $a;                   # fOObar

DESCRIPTION
===========

This module tries to mimic the behaviour of the `substr` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5substr . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

