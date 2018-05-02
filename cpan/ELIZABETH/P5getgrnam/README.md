[![Build Status](https://travis-ci.org/lizmat/P5getgrnam.svg?branch=master)](https://travis-ci.org/lizmat/P5getgrnam)

NAME
====

P5getgrnam - Implement Perl 5's getgrnam() and associated built-ins

SYNOPSIS
========

    use P5getgrnam;

    my @result = getgrnam(~$*USER);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `getgrnam` and associated functions of Perl 5 as closely as possible. It exports:

    endgrent getgrent getgrgid getgrnam

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getgrnam . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

