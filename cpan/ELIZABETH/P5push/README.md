[![Build Status](https://travis-ci.org/lizmat/P5push.svg?branch=master)](https://travis-ci.org/lizmat/P5push)

NAME
====

P5push - Implement Perl 5's push() / pop() built-ins

SYNOPSIS
========

    use P5push;

    my @a = 1,2,3;
    say push @a, 42;  # 4

    say pop;  # pop from @*ARGS, if any

    sub a { dd @_; dd pop; dd @_ }; a 1,2,3;
    [1, 2, 3]
    3
    [1, 2]

DESCRIPTION
===========

This module tries to mimic the behaviour of the `push` and `pop` functions of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5push . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

