[![Build Status](https://travis-ci.org/lizmat/P5rindex.svg?branch=master)](https://travis-ci.org/lizmat/P5rindex)

NAME
====

P5rindex - Implement Perl 5's rindex() built-in [DEPRECATED]

SYNOPSIS
========

    use P5rindex; # exports rindex()

    say rindex("foobar", "bar");    # 3
    say rindex("foofoo", "foo", 4); # 3
    say rindex("foofoo", "bar");    # -1

DESCRIPTION
===========

This module tries to mimic the behaviour of the `rindex` of Perl 5 as closely as possible. It has been deprecated in favour of the `P5index` module, which exports both `rindex` and `index`. Please use that module instead of this one.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5rindex . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

