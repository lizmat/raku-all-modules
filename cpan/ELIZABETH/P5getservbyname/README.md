[![Build Status](https://travis-ci.org/lizmat/P5getservbyname.svg?branch=master)](https://travis-ci.org/lizmat/P5getservbyname)

NAME
====

P5getservbyname - Implement Perl 5's getservbyname() and associated built-ins

SYNOPSIS
========

    use P5getservbyname;
    # exports getservbyname, getservbyport, getservent, setservent, endservent

    say getservbyport(Scalar, 25, "tcp");   # "smtp"

    my @result_byname = getservbyname("smtp");

    my @result_byport = getservbyport(|@result_byname[3,4]);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `getservbyname` and associated functions of Perl 5 as closely as possible. It exports by default:

    endservent getservbyname getservbyport getservent setservent

ORIGINAL PERL 5 DOCUMENTATION
=============================

    getservbyname NAME,PROTO
    getservbyport PORT,PROTO
    getservent
    setservent STAYOPEN
    endservent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $aliases,  $port,      $proto    ) = getserv*

            (If the entry doesn't exist you get an empty list.)

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getservbyname . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

