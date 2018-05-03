[![Build Status](https://travis-ci.org/lizmat/P5getservbyname.svg?branch=master)](https://travis-ci.org/lizmat/P5getservbyname)

NAME
====

P5getservbyname - Implement Perl 5's getservbyname() and associated built-ins

SYNOPSIS
========

    use P5getservbyname;
    # exports getservbyname, getservbyport, getservent, setservent, endservent

    say getservbyport(25, "tcp", :scalar);   # "smtp"

    my @result_byname = getservbyname("smtp");

    my @result_byport = getservbyport(|@result_byname[3,4]);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `getservbyname` and associated functions of Perl 5 as closely as possible. It exports by default:

    endservent getservbyname getservbyport getservent setservent

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getservbyname . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

