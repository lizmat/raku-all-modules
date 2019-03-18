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

ORIGINAL PERL 5 DOCUMENTATION
=============================

    getprotobyname NAME
    getprotobynumber NUMBER
    getprotoent
    setprotoent STAYOPEN
    endprotoent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $aliases,  $proto                ) = getproto*

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.)

            The "getprotobynumber" function, even though it only takes one
            argument, has the precedence of a list operator, so beware:

                getprotobynumber $number eq 'icmp'   # WRONG
                getprotobynumber($number eq 'icmp')  # actually means this
                getprotobynumber($number) eq 'icmp'  # better this way

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getprotobyname . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

