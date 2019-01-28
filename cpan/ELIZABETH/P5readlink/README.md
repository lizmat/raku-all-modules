[![Build Status](https://travis-ci.org/lizmat/P5readlink.svg?branch=master)](https://travis-ci.org/lizmat/P5readlink)

NAME
====

P5readlink - Implement Perl 5's readlink() built-in

SYNOPSIS
========

    use P5readlink;

    say readlink("foobar"); # string if symlink, Nil if not

    with "foobar" {
        say readlink; # string if symlink, Nil if not
    }

DESCRIPTION
===========

This module tries to mimic the behaviour of the `readlink` of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    readlink EXPR
    readlink
            Returns the value of a symbolic link, if symbolic links are
            implemented. If not, raises an exception. If there is a system
            error, returns the undefined value and sets $! (errno). If EXPR is
            omitted, uses $_.

            Portability issues: "readlink" in perlport.

PORTING CAVEATS
===============

Currently `$!` is **not** set when Nil is returned.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5readlink . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

