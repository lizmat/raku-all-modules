[![Build Status](https://travis-ci.org/frithnanth/perl6-Hash-Timeout.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Hash-Timeout)

NAME
====

Hash::Timeout - Role for hashes whose elements timeout and disappear

SYNOPSIS
========

    use Hash::Timeout;

    my %cookies does Hash::Timeout[0.5];
    %cookies<user001> = 'id';
    sleep 1;
    say %cookies.elems; # prints 0

DESCRIPTION
===========

Hash::Timeout provides a `role` that can be mixed with a `Hash`.

There's just one optional parameter, the timeout, which accepts fractional seconds and defaults to 1 hour.

AUTHOR
======

Fernando Santagata <nando.santagata@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

