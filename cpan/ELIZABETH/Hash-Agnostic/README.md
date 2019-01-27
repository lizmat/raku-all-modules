[![Build Status](https://travis-ci.org/lizmat/Hash-Agnostic.svg?branch=master)](https://travis-ci.org/lizmat/Hash-Agnostic)

NAME
====

Hash::Agnostic - be a hash without knowing how

SYNOPSIS
========

    use Hash::Agnostic;
    class MyHash does Hash::Agnostic {
        method AT-KEY($key)          { ... }
        method BIND-KEY($key,$value) { ... }
        method DELETE-KEY($key)      { ... }
        method EXISTS-KEY($key)      { ... }
        method keys()                { ... }
    }

    my %a is MyHash = a => 42, b => 666;

DESCRIPTION
===========

This module makes an `Hash::Agnostic` role available for those classes that wish to implement the `Associative` role as a `Hash`. It provides all of the `Hash` functionality while only needing to implement 5 methods:

Required Methods
----------------

### method AT-KEY

    method AT-KEY($key) { ... }  # simple case

    method AT-KEY($key) { Proxy.new( FETCH => { ... }, STORE => { ... } }

Return the value at the given key in the hash. Must return a `Proxy` that will assign to that key if you wish to allow for auto-vivification of elements in your hash.

### method BIND-KEY

    method BIND-KEY($key, $value) { ... }

Bind the given value to the given key in the hash, and return the value.

### method DELETE-KEY

    method DELETE-KEY($key) { ... }

Remove the the given key from the hash and return its value if it existed (otherwise return `Nil`).

### method EXISTS-KEY

    method EXISTS-KEY($key) { ... }

Return `Bool` indicating whether the key exists in the hash.

### method keys

    method keys() { ... }

Return the keys that currently exist in the hash, in any order that is most convenient.

Optional Methods (provided by role)
-----------------------------------

You may implement these methods out of performance reasons yourself, but you don't have to as an implementation is provided by this role. They follow the same semantics as the methods on the [Hash object](https://docs.perl6.org/type/Hash).

In alphabetical order: `append`, `ASSIGN-KEY`, `elems`, `end`, `gist`, `grab`, `Hash`, `iterator`, `kv`, `list`, `List`, `new`, `pairs`, `perl`, `push`, `Slip`, `STORE`, `Str`, `values`

Optional Internal Methods (provided by role)
--------------------------------------------

These methods may be implemented by the consumer for performance reasons.

### method CLEAR

    method CLEAR(--> Nil) { ... }

Reset the array to have no elements at all. By default implemented by repeatedly calling `DELETE-KEY`, which will by all means, be very slow. So it is a good idea to implement this method yourself.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-Agnostic . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

