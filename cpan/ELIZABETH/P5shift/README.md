[![Build Status](https://travis-ci.org/lizmat/P5shift.svg?branch=master)](https://travis-ci.org/lizmat/P5shift)

NAME
====

P5shift - Implement Perl 5's shift() / unshift() built-ins

SYNOPSIS
========

    use P5shift;

    say shift;  # shift from @*ARGS, if any

    sub a { dd @_; dd shift; dd @_ }; a 1,2,3;
    [1, 2, 3]
    1
    [2, 3]

    my @a = 1,2,3;
    say unshift @a, 42;  # 4

DESCRIPTION
===========

This module tries to mimic the behaviour of the `shift` and `unshift` functions of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    shift ARRAY
    shift EXPR
    shift   Shifts the first value of the array off and returns it, shortening
            the array by 1 and moving everything down. If there are no
            elements in the array, returns the undefined value. If ARRAY is
            omitted, shifts the @_ array within the lexical scope of
            subroutines and formats, and the @ARGV array outside a subroutine
            and also within the lexical scopes established by the "eval
            STRING", "BEGIN {}", "INIT {}", "CHECK {}", "UNITCHECK {}", and
            "END {}" constructs.

            Starting with Perl 5.14, "shift" can take a scalar EXPR, which
            must hold a reference to an unblessed array. The argument will be
            dereferenced automatically. This aspect of "shift" is considered
            highly experimental. The exact behaviour may change in a future
            version of Perl.

            To avoid confusing would-be users of your code who are running
            earlier versions of Perl with mysterious syntax errors, put this
            sort of thing at the top of your file to signal that your code
            will work [4monly[m on Perls of a recent vintage:

                use 5.014;  # so push/pop/etc work on scalars (experimental)

            See also "unshift", "push", and "pop". "shift" and "unshift" do
            the same thing to the left end of an array that "pop" and "push"
            do to the right end.

    unshift ARRAY,LIST
    unshift EXPR,LIST
            Does the opposite of a "shift". Or the opposite of a "push",
            depending on how you look at it. Prepends list to the front of the
            array and returns the new number of elements in the array.

                unshift(@ARGV, '-e') unless $ARGV[0] =~ /^-/;

            Note the LIST is prepended whole, not one element at a time, so
            the prepended elements stay in the same order. Use "reverse" to do
            the reverse.

            Starting with Perl 5.14, "unshift" can take a scalar EXPR, which
            must hold a reference to an unblessed array. The argument will be
            dereferenced automatically. This aspect of "unshift" is considered
            highly experimental. The exact behaviour may change in a future
            version of Perl.

            To avoid confusing would-be users of your code who are running
            earlier versions of Perl with mysterious syntax errors, put this
            sort of thing at the top of your file to signal that your code
            will work only on Perls of a recent vintage:

                use 5.014;  # so push/pop/etc work on scalars (experimental)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5shift . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

