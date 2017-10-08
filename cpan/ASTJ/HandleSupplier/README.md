[![Build Status](https://travis-ci.org/astj/p6-HandleSupplier.svg?branch=master)](https://travis-ci.org/astj/p6-HandleSupplier)

NAME
====

HandleSupplier - generate Supplier for an IO::Handle object

SYNOPSIS
========

    use HandleSupplier;

    my $supplier = supplier-for-handle($*ERR);
    # "hello\n" will be written to STDERR
    $supplier.emit("hello");

DESCRIPTION
===========

HandleSupplier is a utility which provides a Supplier to emit messages to corresponding IO::Handle object.

AUTHOR
======

Asato Wakisaka <asato.wakisaka@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Asato Wakisaka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
