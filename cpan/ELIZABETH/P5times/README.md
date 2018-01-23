[![Build Status](https://travis-ci.org/lizmat/P5times.svg?branch=master)](https://travis-ci.org/lizmat/P5times)

NAME
====

P5times - Implement Perl 5's times() built-in

SYNOPSIS
========

    use P5times; # exports times()

    ($user,$system,$cuser,$csystem) = times;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `times` of Perl 5 as closely as possible.

PORTING CAVEATS
===============

Child process information
-------------------------

There is currently no way to obtain the usage information of child processes.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5times . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

