[![Build Status](https://travis-ci.org/samgwise/Test-SourceFiles.svg?branch=master)](https://travis-ci.org/samgwise/Test-SourceFiles)

NAME
====

Test::SourceFiles - A basic compilation checker

SYNOPSIS
========

    use Test;
    use Test::SourceFiles;

    use-libs-ok;

    done-testing

DESCRIPTION
===========

Test::SourceFiles is a simple way to check the compilation of all files in your projects `lib/` directory. I found myself rewriting this a couple of times so time to make a module.

The simple way is to call the `use-libs-ok` function which calls `Test::use-ok` on each module name returned from the collecting function, `collect-sources`. Alternately you can call `collect-sources` and do something fancy with it's `Seq` of `Pair`'s where the key is a `::` formatted name and the value is the `IO::Path` where it was found. For example:

    say collect-sources.perl
    # prints ("Test::SourceFiles" => IO::Path.new("lib/Test/SourceFiles.pm6", ...),).Seq

Both functions have the following options and defaults:

  * `Str :$root-path = 'lib'` - Where to search for source files

  * `List :$extensions = list 'pm6'` - Which file extensions to include

  * `Bool :$verbose = False` - Provide more detailed feedback on the search process

Use Case
--------

I find this module particularly useful when I'm starting a project, a time where I'm creating a lot of files while stubbing functions and roles. This module weeds out syntax errors from this sketching stage, allowing for a smoother transition into the implementation stage of the development process. As a module matures and it's test suite fills in this module begins to become less useful and so can likely removed later in a module's life.

AUTHOR
======

    Sam Gillespie

COPYRIGHT AND LICENSE
=====================

Copyright 2018

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

