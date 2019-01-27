[![Build Status](https://travis-ci.org/lizmat/Adverb-Eject.svg?branch=master)](https://travis-ci.org/lizmat/Adverb-Eject)

NAME
====

Adverb::Eject - adverb for ejecting elements

SYNOPSIS
========

    use Adverb::Eject;

    my @a = ^10;
    @a[1]:eject; # does *not* return the removed value
    say @a;      # 0 2 3 4 5 6 7 8 9
    @a[1,3,5,7]:eject;
    say @a;      # 0 3 5 7 9

    my %h = a => 42, b => 666, c => 371;
    %h<a>:eject;
    say %h;      # {b => 666, c => 371};
    %h<b c>:eject;
    say %h;      # {}

DESCRIPTION
===========

This module adds the `:eject` adverb to `postcircumfix []` and `postcircumfix { }`. It will remove the indicated elements from the object they're called on (usually an `Array` or a `Hash`) and always return `Nil`, whether something was removed or not.

For `Hash`es, this is similar to the `:delete` adverb, except that it will **not** return the values that have been removed.

For `Array`s, this is **also different** from the `:delete` adverb in that it will actually **remove** the indicated element from the `Array` (as opposed to just resetting the element to its pristine state).

The reason that the `:eject` adverb does not return any of the removed values is because the `:delete` already does that. And for those cases where you do not need the values, the `:eject` adverb has the potential of being more efficiient because it wouldn't have to do the work of producing the values.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Adverb-Eject . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

