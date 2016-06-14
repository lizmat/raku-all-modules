[![Build Status](https://travis-ci.org/skaji/perl6-tail.svg?branch=master)](https://travis-ci.org/skaji/perl6-tail)

NAME
====

IO::TailFile - emulation of tail -f

SYNOPSIS
========

    use IO::TailFile;

    # (a) reactive way
    react {
      whenever IO::TailFile.watch("access.log", :chomp) -> $line {
        say $line;
      };
    };

    # (b) use lazy list
    my @line = IO::TailFile.watch("access.log", :chomp).list.lazy;
    for @line -> $line {
      say $line;
    };

DESCRIPTION
===========

IO::TailFile is a emulation of `tail -f`.

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
