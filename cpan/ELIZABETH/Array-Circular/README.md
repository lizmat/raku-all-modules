[![Build Status](https://travis-ci.org/lizmat/Array-Circular.svg?branch=master)](https://travis-ci.org/lizmat/Array-Circular)

NAME
====

Array::Circular - add "is circular" trait to Arrays

SYNOPSIS
========

    use Array::Circular;

    my @a is circular(3);  # limit to 3 elements

DESCRIPTION
===========

This module adds a `is circular` trait to `Arrays`. This limits the size of the array to the give number of elements, similar to shaped arrays. However, unlike shaped arrays, you **can** `push`, `append`, `unshift` and `prepend` to arrays with the `is circular` trait. Then, if the resulting size of the array is larger than the given size, elements will be removed "from the other end" until the array has the given size again.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Circular . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

