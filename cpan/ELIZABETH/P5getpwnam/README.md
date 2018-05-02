[![Build Status](https://travis-ci.org/lizmat/P5getpwnam.svg?branch=master)](https://travis-ci.org/lizmat/P5getpwnam)

NAME
====

P5getpwnam - Implement Perl 5's getpwnam() and associated built-ins

SYNOPSIS
========

    use P5getpwnam;

    say "logged in as {getlogin || '(unknown)'}";

    my @result = getpwnam(~$*USER);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `getpwnam` and associated functions of Perl 5 as closely as possible. It exports:

    endpwent getlogin getpwent getpwnam getpwuid

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpwnam . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

