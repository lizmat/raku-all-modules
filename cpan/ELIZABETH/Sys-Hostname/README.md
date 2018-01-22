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

Attempts several methods of getting the system hostname and then caches the result. It tries the first available of the C library's gethostname(), uname(2), syscall(SYS_gethostname), `hostname`, `uname -n`, and the file /com/host. If all that fails it dies.

All NULs, returns, and newlines are removed from the result.

PORTING CAVEATS
===============

At present, only `hostname`, `uname -n` and /com/host are attempted before dieing.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sys-Hostname . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Originally developed by David Sundstrom and Greg Bacon. Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

