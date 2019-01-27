[![Build Status](https://travis-ci.org/lizmat/Acme-Don-t.svg?branch=master)](https://travis-ci.org/lizmat/Acme-Don-t)

NAME
====

Acme::Don't - The opposite of do

SYNOPSIS
========

    use Acme::Don't;

    don't { print "This won't be printed\n" };    # NO-OP

DESCRIPTION
===========

The Acme::Don't module provides a `don't` command, which is the opposite of Perl's built-in `do`.

It is used exactly like the `do BLOCK` function except that, instead of executing the block it controls, it...well...doesn't.

Regardless of the contents of the block, `don't` returns `undef`.

You can even write:

    don't {
        # code here
    } while condition();

And, yes, in strict analogy to the semantics of Perl's magical `do...while`, the `don't...while` block is *unconditionally* not done once before the test. ;-)

Note that the code in the `don't` block must be syntactically valid Perl. This is an important feature: you get the accelerated performance of not actually executing the code, without sacrificing the security of compile-time syntax checking.

LIMITATIONS
===========

No opposite
-----------

Doesn't (yet) implement the opposite of `do STRING`. The current workaround is to use:

    don't {"filename"};

Double don'ts
-------------

The construct:

    don't { don't { ... } }

isn't (yet) equivalent to:

    do { ... }

because the outer `don't` prevents the inner `don't` from being executed, before the inner `don't` gets the chance to discover that it actually *should* execute.

This is an issue of semantics. `don't...` doesn't mean `do the opposite of...`; it means `do nothing with...`.

In other words, doin nothing about doing nothing does...nothing.

Unless not
----------

You can't (yet) use a:

    don't { ... } unless condition();

as a substitute for:

    do { ... } if condition();

Again, it's an issue of semantics. `don't...unless...` doesn't mean `do the opposite of...if...`; it means `do nothing with...if not...`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Acme-don-t . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Original author: Damian Conway. Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

