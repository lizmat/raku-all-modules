[![Build Status](https://travis-ci.org/lizmat/P5times.svg?branch=master)](https://travis-ci.org/lizmat/P5times)

NAME
====

P5times - Implement Perl 5's times() built-in

SYNOPSIS
========

    use P5times; # exports times()

    ($user,$system,$cuser,$csystem) = times;

    $user = times(Scalar);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `times` function of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    times   Returns a four-element list giving the user and system times in
            seconds for this process and any exited children of this process.

                ($user,$system,$cuser,$csystem) = times;

            In scalar context, "times" returns $user.

            Children's times are only included for terminated children.

            Portability issues: "times" in perlport.

PORTING CAVEATS
===============

Child process information
-------------------------

There is currently no way to obtain the usage information of child processes.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5times . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

