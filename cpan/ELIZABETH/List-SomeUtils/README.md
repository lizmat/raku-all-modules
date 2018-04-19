[![Build Status](https://travis-ci.org/lizmat/List-SomeUtils.svg?branch=master)](https://travis-ci.org/lizmat/List-SomeUtils)

NAME
====

List::SomeUtils - Port of Perl 5's List::SomeUtils 0.56

SYNOPSIS
========

    # import specific functions
    use List::SomeUtils <any uniq>;

    if any { /foo/ }, uniq @has_duplicates {
        # do stuff
    }

    # import everything
    use List::SomeUtils ':all';

DESCRIPTION
===========

List::SomeUtils is a functional copy of [List::MoreUtils](List::MoreUtils). As for the reasons of its existence, please check the documentation of the Perl 5 version.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

