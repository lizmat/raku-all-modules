[![Build Status](https://travis-ci.org/lizmat/Attribute-Predicate.svg?branch=master)](https://travis-ci.org/lizmat/Attribute-Predicate)

NAME
====

Attribute::Predicate - add "is predicate" trait to Attributes

SYNOPSIS
========

    use Attribute::Predicate;

    class Foo {
        has $.bar is predicate;         # adds method "has-bar"
        has $.baz is predicate<bazzy>;  # adds method "bazzy"
    }

    Foo.new(bar => 42).has-bar;    # True
    Foo.new(bar => 42).bazzy;      # False

DESCRIPTION
===========

This module adds a `is predicate` trait to `Attributes`. It is similar in function to the "predicate" option of Perl 5's `Moo` and `Moose` object systems.

If specified without any additional information, it will create a method with the name "has-{attribute.name}". If a specific string is specified, then it will create the method with that given name.

The method in question will return a `Bool` indicating whether the attribute has a defined value.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Attribute-Predicate . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

