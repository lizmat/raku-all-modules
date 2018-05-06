[![Build Status](https://travis-ci.org/lizmat/P5print.svg?branch=master)](https://travis-ci.org/lizmat/P5print)

NAME
====

P5print - Implement Perl 5's print() and associated built-ins

SYNOPSIS
========

    use P5print; # exports print, printf, say, STDIN, STDOUT, STDERR

    print STDOUT, "foo";

    printf STDERR, "%s", $bar;

    say STDERR, "foobar";      # same as "note"

DESCRIPTION
===========

This module tries to mimic the behaviour of the `print`, `printf` and `say` builtin functions of Perl 5 as closely as possible.

PORTING CAVEATS
===============

In Perl 6, there **must** be a comma after the handle, as opposed to Perl 5 where the whitespace after the handle indicates indirect object syntax.

    print STDERR "whee!";   # Perl 5 way

    print STDERR, "whee!";  # Perl 6 mimicing Perl 5

Perl 6 warnings on P5-isms kick in when calling `print` or `say` without any parameters or parentheses. This warning can be circumvented by adding `()` to the call, so:

    print;   # will complain
    print(); # won't complain and print $_

IDIOMATIC PERL 6 WAYS
=====================

When needing to write to specific handle, it's probably easier to use the method form.

    $handle.print("foo");
    $handle.printf("foo");
    $handle.say("foo");

If you want to do a `say` on `STDERR`, this is easier done with the `note` builtin function:

    $*ERR.say("foo");  # "foo\n" on standard error
    note "foo";        # same

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5print . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

