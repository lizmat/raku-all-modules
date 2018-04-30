[![Build Status](https://travis-ci.org/lizmat/P5localtime.svg?branch=master)](https://travis-ci.org/lizmat/P5localtime)

NAME
====

P5localtime - Implement Perl 5's localtime / gmtime built-ins

SYNOPSIS
========

    use P5localtime;

    #     0    1    2     3     4    5     6     7     8
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    say localtime(time, :scalar);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    say gmtime(time, :scalar);

DESCRIPTION
===========

This module tries to mimic the behaviour of the `localtime` and `gmtime` functions of Perl 5 as closely as possible.

PORTING CAVEATS
---------------

Since Perl 6 does not have a concept of scalar context, this must be mimiced by passing the `:scalar` named parameter.

The implementation actually also returns the offset in GMT in seconds as element number 9, and the name of the timezone as element number 10, if supported by the OS.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5localtime . Comments and Pull Requests are welcome.

ACKNOWLEDGEMENTS
================

JJ Merelo, Jan-Olof Hendig, Tobias Leich, Timo Paulssen and Christoph (on StackOverflow) for support in getting this to work.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

