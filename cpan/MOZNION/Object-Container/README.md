[![Build Status](https://travis-ci.org/moznion/p6-Object-Container.svg?branch=master)](https://travis-ci.org/moznion/p6-Object-Container)

NAME
====

Object::Container - A simple container for object for perl6

SYNOPSIS
========

Instance method
---------------

    use Object::Container;

    my $container = Object::Container.new;

    $container.register('obj1', $obj1);
    $container.register('obj2', $obj2);

    $container.get('obj1');        # <= equals $obj1
    $container.get('obj2');        # <= equals $obj2
    $container.get('not-existed'); # <= equals Nil

Class method (singleton)
------------------------

    use Object::Container;

    Object::Container.register('obj1', $obj1);
    Object::Container.register('obj2', $obj2);

    Object::Container.get('obj1');        # <= equals $obj1
    Object::Container.get('obj2');        # <= equals $obj2
    Object::Container.get('not-existed'); # <= equals Nil

DESCRIPTION
===========

Object::Container is a simple container for object. A simple DI mechanism can be implemented easily by using this module. This module provides following features;

  * Register object to container

  * Find object from container

  * Remove registered object from container

  * Clear container

METHODS
=======

`register(Str:D $name, Any:D $object)`
--------------------------------------

Registers the instantiated object with name in the container.

`register(Str:D $name, Callable:D $initializer)`
------------------------------------------------

Registers the `Callable` as initializer to instantiate the object with the name in the container. This method instantiates the object with calling `Callable`. This is a **lazy** way to instantiate; it means it defers instantiation (i.e. calling `Callable`) until `get(...)` is invoked.

    my $container = Object::Container.new;
    my $initializer = sub {
        # Reach here when `$container.get()` is called (only at once)
        return $something;
    };
    $container.register('obj-name', $initializer);

`get(Str:D $name) returns Any`
------------------------------

Finds the registered object from the container by the name and return it. If the object is missing, it returns `Nil`.

`remove(Str:D $name) returns Bool`
----------------------------------

Removes the registered object from the container by the name. It returns whether the registered object was existed in the container or not.

`clear()`
---------

Clears the container. In other words, it rewinds the container to its initial state.

Singleton pattern
=================

If you use this module with class method (e.g. `Object::Container.register(...)`), this module handles the container as singleton object.

AUTHOR
======

moznion <moznion@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017- moznion

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
