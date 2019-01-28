[![Build Status](https://travis-ci.org/lizmat/P5seek.svg?branch=master)](https://travis-ci.org/lizmat/P5seek)

NAME
====

P5seek - Implement Perl 5's seek() built-in

SYNOPSIS
========

    use P5seek;

    seek($filehandle, 42, 0);

    seek($filehandle, 42, SEEK_SET); # same, SEEK_CUR / SEEK_END also available

DESCRIPTION
===========

This module tries to mimic the behaviour of the `seek` function of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    seek FILEHANDLE,POSITION,WHENCE
            Sets FILEHANDLE's position, just like the "fseek" call of "stdio".
            FILEHANDLE may be an expression whose value gives the name of the
            filehandle. The values for WHENCE are 0 to set the new position in
            bytes to POSITION; 1 to set it to the current position plus
            POSITION; and 2 to set it to EOF plus POSITION, typically
            negative. For WHENCE you may use the constants "SEEK_SET",
            "SEEK_CUR", and "SEEK_END" (start of the file, current position,
            end of the file) from the Fcntl module. Returns 1 on success,
            false otherwise.

            Note the in bytes: even if the filehandle has been set to operate
            on characters (for example by using the ":encoding(utf8)" open
            layer), tell() will return byte offsets, not character offsets
            (because implementing that would render seek() and tell() rather
            slow).

            If you want to position the file for "sysread" or "syswrite",
            don't use "seek", because buffering makes its effect on the file's
            read-write position unpredictable and non-portable. Use "sysseek"
            instead.

            Due to the rules and rigors of ANSI C, on some systems you have to
            do a seek whenever you switch between reading and writing. Amongst
            other things, this may have the effect of calling stdio's
            clearerr(3). A WHENCE of 1 ("SEEK_CUR") is useful for not moving
            the file position:

                seek(TEST,0,1);

            This is also useful for applications emulating "tail -f". Once you
            hit EOF on your read and then sleep for a while, you (probably)
            have to stick in a dummy seek() to reset things. The "seek"
            doesn't change the position, but it does clear the end-of-file
            condition on the handle, so that the next "<FILE>" makes Perl try
            again to read something. (We hope.)

            If that doesn't work (some I/O implementations are particularly
            cantankerous), you might need something like this:

                for (;;) {
                    for ($curpos = tell(FILE); $_ = <FILE>;
                         $curpos = tell(FILE)) {
                        # search for some stuff and put it into files
                    }
                    sleep($for_a_while);
                    seek(FILE, $curpos, 0);
                }

PORTING CAVEATS
===============

For convenience, the terms `SEEK_SET`, `SEEK_CUR` and `SEEK_END` are also exported.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5seek . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

