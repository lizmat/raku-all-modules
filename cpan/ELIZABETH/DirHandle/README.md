[![Build Status](https://travis-ci.org/lizmat/DirHandle.svg?branch=master)](https://travis-ci.org/lizmat/DirHandle)

NAME
====

DirHandle - Port of Perl 5's DirHandle

SYNOPSIS
========

    use DirHandle;
    with Dirhandle.new(".") -> $d {
        while $d.read -> $entry { something($entry) }
        $d->rewind;
        while $d.read(:void) { something_else($_) }
        $d.close;
    }

DESCRIPTION
===========

The DirHandle object provides an alternative interface to the `opendir`, `closedir`, `readdir`, `telldir`, `seekdir` and `rewinddir` functions.

The only objective benefit to using DirHandle is that it avoids namespace pollution.

PORTING CAVEATS
===============

Since Perl 6 does not have a concept like void context, one needs to specify a `:void` named parameter with `read` to mimic the behaviour of `DirHandle.read` of Perl 5 in void context.

The Perl 5 version of `DirHandle` for some mysterious reason does not contain methods for performing a `telldir` or a `seekdir`. The Perl 6 version **does** contain equivalent methods `tell` and `seek`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/DirHandle . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

