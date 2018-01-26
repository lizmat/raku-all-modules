[![Build Status](https://travis-ci.org/lizmat/P5chop.svg?branch=master)](https://travis-ci.org/lizmat/P5chop)

NAME
====

P5chop - Implement Perl 5's chop() built-in

SYNOPSIS
========

    use P5chop; # exports chop()

    chop $a;
    chop @a;
    chop %h;
    chop($a,$b);
    chop();      # bare chop may be compilation error to prevent P5isms in Perl 6

DESCRIPTION
===========

This module tries to mimic the behaviour of the `chop` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chop . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

