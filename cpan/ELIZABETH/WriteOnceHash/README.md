[![Build Status](https://travis-ci.org/lizmat/WriteOnceHash.svg?branch=master)](https://travis-ci.org/lizmat/WriteOnceHash)

NAME
====

WriteOnceHash - be a Hash in which each key can only be set once

SYNOPSIS
========

    use WriteOnceHash;

    # bind to predefined class
    my %woh is WriteOnceHash;
    %woh<a> = 5; # ok
    %woh<a> = 1; # throws
      
    CATCH {
        when X::Hash::WriteOnce {
            say "Sorry, already set {.key} before";
            .resume
        }
    }

    # mix in role on anything that does Associative
    my %owoh{Any} does WriteOnce;

DESCRIPTION
===========

This module makes an `WriteOnceHash` class available that can be used instead of the normal `Hash`. The only difference with a normal `Hash` is, is that if an attempt is made to set the value of a key that **has already been set before**, that then an exception is thrown rather than just overwriting the key in the `Hash`.

Also exports a `X::Hash::WriteOnce` error class that will be thrown if an attempt is made to set a key again.

The underlying `WriteOnce` role is also exported that can be used on objects that perform the `Associative` role that are not `Hash` (such as object hashes).

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/WriteOnceHash . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

