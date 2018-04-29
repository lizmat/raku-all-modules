[![Build Status](https://travis-ci.org/lizmat/P5opendir.svg?branch=master)](https://travis-ci.org/lizmat/P5opendir)

NAME
====

P5opendir - Implement Perl 5's opendir() and related built-ins

SYNOPSIS
========

    # exports opendir, readdir, telldir, seekdir, rewinddir, closedir
    use P5opendir;

    opendir(my $dh, $some_dir) || die "can't opendir $some_dir: $!";
    my @dots = grep { .starts-with('.') && "$some_dir/$_".IO.f }, readdir($dh);
    closedir $dh;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `opendir`, `readdir`, `telldir`, `seekdir`, `rewinddir` and `closedir` functions of Perl 5 as closely as possible.

PORTING CAVEATS
===============

The `readdir` function has three modes:

list mode
---------

By default, `readdir` returns a list with all directory entries found.

    my @entries = readdir($dh);

scalar context
--------------

In scalar context, `readdir` returns one directory entry at a time. Add the `:scalar` named variable to mimic this behaviour:

    while readdir($dh, :scalar) -> $entry {
        say "found $entry";
    }

void context
------------

In void context, `readdir` stores one directory entry at a time in `$_`. Add the `:void` named variable to mimic this behaviour:

    .say while readdir($dh, :void);

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5opendir . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

