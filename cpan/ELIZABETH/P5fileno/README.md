[![Build Status](https://travis-ci.org/lizmat/P5fileno.svg?branch=master)](https://travis-ci.org/lizmat/P5fileno)

NAME
====

P5fileno - Implement Perl 5's fileno() built-in

SYNOPSIS
========

    use P5fileno;

    say fileno $*IN;    # 0
    say fileno $*OUT;   # 1
    say fileno $*ERR;   # 2
    say fileno $foo;    # something like 16

DESCRIPTION
===========

This module tries to mimic the behaviour of the `fileno` function of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    fileno FILEHANDLE
            Returns the file descriptor for a filehandle, or undefined if the
            filehandle is not open. If there is no real file descriptor at the
            OS level, as can happen with filehandles connected to memory
            objects via "open" with a reference for the third argument, -1 is
            returned.

            This is mainly useful for constructing bitmaps for "select" and
            low-level POSIX tty-handling operations. If FILEHANDLE is an
            expression, the value is taken as an indirect filehandle,
            generally its name.

            You can use this to find out whether two handles refer to the same
            underlying descriptor:

                if (fileno(THIS) != -1 && fileno(THIS) == fileno(THAT)) {
                    print "THIS and THAT are dups\n";
                } elsif (fileno(THIS) != -1 && fileno(THAT) != -1) {
                    print "THIS and THAT have different " .
                        "underlying file descriptors\n";
                } else {
                    print "At least one of THIS and THAT does " .
                        "not have a real file descriptor\n";
                }

IDIOMATIC PERL 6 WAY
====================

The file descriptor of a file handle is exposed with the `native-descriptor` method on `IO::Handle`:

    say $*OUT.native-descriptor;   # 1

PORTING CAVEATS
===============

When calling with an unopened `IO::Handle`, this version will return `Nil`. That's the closest thing there is to `undef` in Perl 6.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5fileno . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

