[![Build Status](https://travis-ci.org/lizmat/P5index.svg?branch=master)](https://travis-ci.org/lizmat/P5index)

NAME
====

P5index - Implement Perl 5's index() / rindex() built-ins

SYNOPSIS
========

    use P5index; # exports index() / rindex()

    say index("foobar", "bar");    # 3
    say index("foofoo", "foo", 1); # 3
    say index("foofoo", "bar");    # -1

    say rindex("foobar", "bar");    # 3
    say rindex("foofoo", "foo", 4); # 3
    say rindex("foofoo", "bar");    # -1

DESCRIPTION
===========

This module tries to mimic the behaviour of the `index` / `rindex` built-ins of Perl 5 as closely as possible.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5index . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

