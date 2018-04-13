[![Build Status](https://travis-ci.org/lizmat/P5chomp.svg?branch=master)](https://travis-ci.org/lizmat/P5chomp)

NAME
====

P5chomp - Implement Perl 5's chomp() / chop() built-ins

SYNOPSIS
========

    use P5chomp; # exports chomp() and chop()

    chomp $a;
    chomp @a;
    chomp %h;
    chomp($a,$b);
    chomp();   # bare chomp may be compilation error to prevent P5isms in Perl 6

    chop $a;
    chop @a;
    chop %h;
    chop($a,$b);
    chop();      # bare chop may be compilation error to prevent P5isms in Perl 6

DESCRIPTION
===========

This module tries to mimic the behaviour of the `chomp` and `chop` built-ins of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chomp . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

