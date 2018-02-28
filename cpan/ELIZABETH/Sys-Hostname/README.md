[![Build Status](https://travis-ci.org/lizmat/Sys-Hostname.svg?branch=master)](https://travis-ci.org/lizmat/Sys-Hostname)

NAME
====

Sys::Hostname - Implement Perl 5's Sys::Hostname core module

SYNOPSIS
========

    use Sys::Hostname;
    $host = hostname;

DESCRIPTION
===========

Obtain the system hostname as Perl 6 sees it.

All NULs, returns, and newlines are removed from the result.

PORTING CAVEATS
===============

At present, the behaviour of the built-in `gethostname` sub is used. Any bugs in its behaviour should be fixed there.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sys-Hostname . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Originally developed by David Sundstrom and Greg Bacon. Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

