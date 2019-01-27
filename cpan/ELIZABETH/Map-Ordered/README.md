[![Build Status](https://travis-ci.org/lizmat/Map-Ordered.svg?branch=master)](https://travis-ci.org/lizmat/Map-Ordered)

NAME
====

Map::Ordered - role for ordered Maps

SYNOPSIS
========

    use Map::Ordered;

    my %m is Map::Ordered = a => 42, b => 666;

DESCRIPTION
===========

Exports a `Map::Ordered` role that can be used to indicate the implementation of a `Map` in which the keys are ordered the way the `Map` got initialized.

Since `Map::Ordered` is a role, you can also use it as a base for creating your own custom implementations of maps.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Map-Ordered . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

