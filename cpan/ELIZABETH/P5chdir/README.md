[![Build Status](https://travis-ci.org/lizmat/P5chdir.svg?branch=master)](https://travis-ci.org/lizmat/P5chdir)

NAME
====

P5chdir - Implement Perl 5's chdir() built-in

SYNOPSIS
========

    use P5chdir;

    say "switched" if chdir; # switched to HOME or LOGDIR

    say "switched" if chdir("lib");

DESCRIPTION
===========

This module tries to mimic the behaviour of the `chdir` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chdir . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

