[![Build Status](https://travis-ci.org/lizmat/Array-Agnostic.svg?branch=master)](https://travis-ci.org/lizmat/Array-Agnostic)

NAME
====

Array::Agnostic - be an array without knowing how

SYNOPSIS
========

    use Array::Agnostic;
    class MyArray does Array::Agnostic {
        method AT-POS()     { ... }
        method BIND-POS()   { ... }
        method DELETE-POS() { ... }
        method EXISTS-POS() { ... }
        method elems()      { ... }
    }

    my @a is MyArray = 1,2,3;

DESCRIPTION
===========

This module makes an `Array::Agnostic` role available for those classes that wish to implement the `Positional` role as an `Array`. It provides all of the `Array` functionality while only needing to implement 5 methods:

Required Methods
----------------

### method AT-POS

    method AT-POS($position) { ... }  # simple case

    method AT-POS($position) { Proxy.new( FETCH => { ... }, STORE => { ... } }

Return the value at the given position in the array. Must return a `Proxy` that will assign to that position if you wish to allow for auto-vivification of elements in your array.

### method BIND-POS

    method BIND-POS($position, $value) { ... }

Bind the given value to the given position in the array, and return the value.

### method DELETE-POS

    method DELETE-POS($position) { ... }

Mark the element at the given position in the array as absent (make `EXISTS-POS` return `False` for this position).

### method EXISTS-POS

    method EXISTS-POS($position) { ... }

Return `Bool` indicating whether the element at the given position exists (aka, is **not** marked as absent).

### method elems

    method elems(--> Int:D) { ... }

Return the number of elements in the array (defined as the index of the highest element + 1).

Optional Methods (provided by role)
-----------------------------------

You may implement these methods out of performance reasons yourself, but you don't have to as an implementation is provided by this role. They follow the same semantics as the methods on the [Array object](https://docs.perl6.org/type/Array).

In alphabetical order: `append`, `Array`, `ASSIGN-POS`, `end`, `gist`, `grab`, `iterator`, `keys`, `kv`, `list`, `List`, `new`, `pairs`, `perl`, `pop`, `prepend`, `push`, `shape`, `shift`, `Slip`, `STORE`, `Str`, `splice`, `unshift`, `values`

Optional Internal Methods (provided by role)
--------------------------------------------

These methods may be implemented by the consumer for performance reasons.

### method CLEAR

    method CLEAR(--> Nil) { ... }

Reset the array to have no elements at all. By default implemented by repeatedly calling `DELETE-POS`, which will by all means, be very slow. So it is a good idea to implement this method yourself.

### method move-indexes-up

    method move-indexes-up($up, $start = 0) { ... }

Add the given value to the **indexes** of the elements in the array, optionally starting from a given start index value (by default 0, so all elements of the array will be affected). This functionality is needed if you want to be able to use `shift`, `unshift` and related functions.

### method move-indexes-down

    method move-indexes-down($down, $start = $down) { ... }

Subtract the given value to the **indexes** of the elements in the array, optionally starting from a given start index value (by default the same as the number to subtract, so that all elements of the array will be affected. This functionality is needed if you want to be able to use `shift`, `unshift` and related functions.

Exported subroutines
--------------------

### sub is-container

    my $a = 42;
    say is-container($a);  # True
    say is-container(42);  # False

Returns whether the given argument is a container or not. This can be handy for situations where you want to also support binding, **and** allow for methods such as `shift`, `unshift` and related functions.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Agnostic . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

