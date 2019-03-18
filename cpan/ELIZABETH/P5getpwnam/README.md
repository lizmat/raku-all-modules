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

    endpwent getlogin getpwent getpwnam getpwuid setpwent

ORIGINAL PERL 5 DOCUMENTATION
=============================

    getpwnam NAME
    getpwuid UID
    getpwent
    setpwent
    endpwent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $passwd,   $uid,       $gid,     $quota,
             $comment,  $gcos,     $dir,       $shell,   $expire ) = getpw*
             # 5        6          7           8         9

            (If the entry doesn't exist you get an empty list.)

            The exact meaning of the $gcos field varies but it usually
            contains the real name of the user (as opposed to the login name)
            and other information pertaining to the user. Beware, however,
            that in many system users are able to change this information and
            therefore it cannot be trusted and therefore the $gcos is tainted
            (see perlsec). The $passwd and $shell, user's encrypted password
            and login shell, are also tainted, for the same reason.

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.) For
            example:

                $uid   = getpwnam($name);
                $name  = getpwuid($num);

            In getpw*() the fields $quota, $comment, and $expire are special
            in that they are unsupported on many systems. If the $quota is
            unsupported, it is an empty scalar. If it is supported, it usually
            encodes the disk quota. If the $comment field is unsupported, it
            is an empty scalar. If it is supported it usually encodes some
            administrative comment about the user. In some systems the $quota
            field may be $change or $age, fields that have to do with password
            aging. In some systems the $comment field may be $class. The
            $expire field, if present, encodes the expiration period of the
            account or the password. For the availability and the exact
            meaning of these fields in your system, please consult getpwnam(3)
            and your system's pwd.h file. You can also find out from within
            Perl what your $quota and $comment fields mean and whether you
            have the $expire field by using the "Config" module and the values
            "d_pwquota", "d_pwage", "d_pwchange", "d_pwcomment", and
            "d_pwexpire". Shadow password files are supported only if your
            vendor has implemented them in the intuitive fashion that calling
            the regular C library routines gets the shadow versions if you're
            running under privilege or if there exists the shadow(3) functions
            as found in System V (this includes Solaris and Linux). Those
            systems that implement a proprietary shadow password facility are
            unlikely to be supported.

    getlogin
            This implements the C library function of the same name, which on
            most systems returns the current login from /etc/utmp, if any. If
            it returns the empty string, use "getpwuid".

                $login = getlogin || getpwuid($<) || "Kilroy";

            Do not consider "getlogin" for authentication: it is not as secure
            as "getpwuid".

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpwnam . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

