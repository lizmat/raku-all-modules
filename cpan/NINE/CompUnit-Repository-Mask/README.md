[![Build Status](https://travis-ci.org/niner/CompUnit-Repository-Mask.svg?branch=master)](https://travis-ci.org/niner/CompUnit-Repository-Mask)

NAME
====

CompUnit::Repository::Mask - hide installed modules for testing.

SYNOPSIS
========

    use CompUnit::Repository::Mask :mask-module, :unmask-module;
    mask-module('Test');
    try require Test; # now fails
    unmask-module('Test');
    require Test; # succeeds

DESCRIPTION
===========

CompUnit::Repository::Mask helps testing code dealing with optional dependencies. It allows for masking and unmasking installed modules, so you can write tests for when the dependency is missing and for when it's installed.

AUTHOR
======

Stefan Seifert <nine@detonation.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Stefan Seifert

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
