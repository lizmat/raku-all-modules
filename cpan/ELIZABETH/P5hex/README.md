[![Build Status](https://travis-ci.org/lizmat/P5hex.svg?branch=master)](https://travis-ci.org/lizmat/P5hex)

NAME
====

P5hex - Implement Perl 5's hex() / ord() built-ins

SYNOPSIS
========

    use P5hex; # exports hex() and ord()

    print hex '0xAf'; # prints '175'
    print hex 'aF';   # same

    $val = oct($val) if $val =~ /^0/;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `hex` and `oct` built-ins of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5hex . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

