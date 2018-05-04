[![Build Status](https://travis-ci.org/lizmat/P5getprotobyname.svg?branch=master)](https://travis-ci.org/lizmat/P5getprotobyname)

NAME
====

P5getprotobyname - Implement Perl 5's getprotobyname() and associated built-ins

SYNOPSIS
========

    use P5getprotobyname;
    # exports getprotobyname, getprotobyport, getprotoent, setprotoent, endprotoent

    say getprotobynumber(0, :scalar);   # "ip"

    my @result_byname = getprotobyname("ip");

    my @result_bynumber = getprotobynumber(@result_byname[2]);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `getprotobyname` and associated functions of Perl 5 as closely as possible. It exports by default:

    endprotoent getprotobyname getprotobynumber getprotoent setprotoent

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getprotobyname . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

