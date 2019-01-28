[![Build Status](https://travis-ci.org/lizmat/unprint.svg?branch=master)](https://travis-ci.org/lizmat/unprint)

NAME
====

unprint - provide fast print / say / put

SYNOPSIS
========

    use unprint;

    print "foo";
    say "bar";
    put 42;

DESCRIPTION
===========

This module provides fast `print`, `say` and `put` subroutines that will directly write to STDOUT of the OS without any overhead caused by determining which `$*OUT` to actually use. As such, this should give you similar speeds as Perl 5's output.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/unprint . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

