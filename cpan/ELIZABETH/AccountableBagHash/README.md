[![Build Status](https://travis-ci.org/lizmat/AccountableBagHash.svg?branch=master)](https://travis-ci.org/lizmat/AccountableBagHash)

NAME
====

AccountableBagHash - be an accountable BagHash

SYNOPSIS
========

    use AccountableBagHash;

    my %abh is AccountableBagHash = a => 42, b => 666;
    %abh<a> =  5; # ok
    %abh<a> = -1; # throws
      
    CATCH {
        when X::BagHash::Acountable {
            say "You do not have enough {.key}";
            .resume
        }
    }

DESCRIPTION
===========

This module makes an `AccountableBagHash` class available that can be used instead of the normal `BagHash`. The only difference with a normal `BagHash` is, is that if an attempt is made to set the value of a key to **less than 0**, that then an exception is thrown rather than just deleting the key from the `BagHash`.

Also exports a `X::BagHash::Acountable` error class that will be thrown if an attempt is made to set the value to below 0.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/AccountableBagHash . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

