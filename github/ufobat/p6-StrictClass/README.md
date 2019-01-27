[![Build Status](https://travis-ci.org/ufobat/p6-StrictClass.svg?branch=master)](https://travis-ci.org/ufobat/p6-StrictClass)

NAME
====

StrictClass - Make your object constructors blow up on unknown attributes

SYNOPSIS
========

    use StrictClass;

    class MyClass does StrictClass {
        has $.foo;
        has $.bar;
    }

    MyClass.new( :foo(1), :bar(2), :baz('makes you explode'));

DESCRIPTION
===========

Simply using this role for your class makes your `new` "strict". This is a great way to catch small typos.

AUTHOR
======

Martin Barth <martin@senfdax.de>

head
====

THANKS TO

    * FCO aka SmokeMaschine from #perl6 IRC channel for this code.
    * Dave Rolsky for his perl5 module `MooseX::StrictContructor`.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Martin Barth

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

