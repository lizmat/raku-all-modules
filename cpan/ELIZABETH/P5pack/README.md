[![Build Status](https://travis-ci.org/lizmat/P5pack.svg?branch=master)](https://travis-ci.org/lizmat/P5pack)

NAME
====

P5times - Implement Perl 5's pack()/unpack() built-ins

SYNOPSIS
========

    use P5pack; # exports pack(), unpack()

DESCRIPTION
===========

Implements Perl 5's `pack`/`unpack` functionality efficiently in Perl 6.

Currently supported directives are: a A c C h H i I l L n N q Q s S U v V x Z

PORTING CAVEATS
===============

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5pack . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan and an earlier version that only lived in the Perl 6 Ecosystem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

