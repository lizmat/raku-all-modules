[![Build Status](https://travis-ci.org/lizmat/P5ref.svg?branch=master)](https://travis-ci.org/lizmat/P5ref)

NAME
====

P5ref - Implement Perl 5's ref() built-in

SYNOPSIS
========

    use P5ref; # exports ref()

    my @a;
    say ref @a;  # ARRAY

    my %h;
    say ref %h;  # HASH

    sub &a { };
    say ref &a;  # CODE

    my $r = /foo/;
    say ref $r;  # Regexp

    my $v = v6.c;
    say ref $v;  # VSTRING

    my $i = 42;
    say ref $i;  # Int

DESCRIPTION
===========

This module tries to mimic the behaviour of the `ref` of Perl 5 as closely as possible.

HEAD1
=====

ORIGINAL PERL 5 DOCUMENTATION

    ref EXPR
    ref     Returns a non-empty string if EXPR is a reference, the empty
            string otherwise. If EXPR is not specified, $_ will be used. The
            value returned depends on the type of thing the reference is a
            reference to.

            Builtin types include:

                SCALAR
                ARRAY
                HASH
                CODE
                REF
                GLOB
                LVALUE
                FORMAT
                IO
                VSTRING
                Regexp

            You can think of "ref" as a "typeof" operator.

                if (ref($r) eq "HASH") {
                    print "r is a reference to a hash.\n";
                }
                unless (ref($r)) {
                    print "r is not a reference at all.\n";
                }

            The return value "LVALUE" indicates a reference to an lvalue that
            is not a variable. You get this from taking the reference of
            function calls like "pos()" or "substr()". "VSTRING" is returned
            if the reference points to a version string.

            The result "Regexp" indicates that the argument is a regular
            expression resulting from "qr//".

            If the referenced object has been blessed into a package, then
            that package name is returned instead. But don't use that, as it's
            now considered "bad practice". For one reason, an object could be
            using a class called "Regexp" or "IO", or even "HASH". Also, "ref"
            doesn't take into account subclasses, like "isa" does.

            Instead, use "blessed" (in the Scalar::Util module) for boolean
            checks, "isa" for specific class checks and "reftype" (also from
            Scalar::Util) for type checks. (See perlobj for details and a
            "blessed/isa" example.)

            See also perlref.

PORTING CAVEATS
===============

Types not supported
-------------------

The following strings are currently never returned by `ref` because they have no sensible equivalent in Perl 6: `REF`, `GLOB`, `LVALUE`, `FORMAT`, `IO`.

Also, since everything in Perl 6 is a (blessed) object, you can only get the `SCALAR` response if you managed to put a Scalar container into another Scalar container (which is pretty hard), or you somehow have gotten ahold of a Proxy object. On all other cases, a Scalar container will be ignored and instead the contents of the container will be used.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ref . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

