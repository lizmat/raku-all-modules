[![Build Status](https://travis-ci.org/lizmat/P5chr.svg?branch=master)](https://travis-ci.org/lizmat/P5chr)

NAME
====

P5chr - Implement Perl 5's chr() built-in

SYNOPSIS
========

    use P5chr; # exports chr()

    my $a = 65;
    say chr $a;

    $_ = 65;
    say chr();      # bare chr may be compilation error to prevent P5isms in Perl 6

DESCRIPTION
===========

This module tries to mimic the behaviour of the `chr` of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chr . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

