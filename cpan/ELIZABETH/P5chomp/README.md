[![Build Status](https://travis-ci.org/lizmat/P5chomp.svg?branch=master)](https://travis-ci.org/lizmat/P5chomp)

NAME
====

P5chomp - Implement Perl 5's chomp() built-in

SYNOPSIS
========

    use P5chomp; # exports chomp()

    chomp $a;
    chomp @a;
    chomp %h;
    chomp($a,$b);
    chomp();      # bare chomp may be compilation error to prevent P5isms in Perl 6

DESCRIPTION
===========

This module tries to mimic the behaviour of the `chomp` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chomp . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

