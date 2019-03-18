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

    endgrent getgrent getgrgid getgrnam setgrent

ORIGINAL PERL 5 DOCUMENTATION
=============================

    getgrnam NAME
    getgrgid GID
    getgrent
    setgrent
    endgrent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $passwd,   $gid,       $members  ) = getgr*

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.) For
            example:

                $gid   = getgrnam($name);
                $name  = getgrgid($num);

            The $members value returned by getgr*() is a space-separated list
            of the login names of the members of the group.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getgrnam . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

