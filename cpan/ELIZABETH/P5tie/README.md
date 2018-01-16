[![Build Status](https://travis-ci.org/lizmat/P5tie.svg?branch=master)](https://travis-ci.org/lizmat/P5tie)

NAME
====

P5tie - Implement Perl 5's tie() built-in

SYNOPSIS
========

    use P5tie; # exports tie(), tied() and untie()

    tie my $s, Tie::AsScalar;
    tie my @a, Tie::AsArray;
    tie my %h, Tie::AsHash;

    $object = tied $s;
    untie $s;

DESCRIPTION
===========

This module tries to mimic the behaviour of the `tie` of Perl 5 as closely as possible. Please note that there are usually better ways attaching special functionality to arrays, hashes and scalars in Perl 6 than using `tie`. Please see the documentation on [Custom Types](https://docs.perl6.org/language/subscripts#Custom_types) for more information to handling the needs that Perl 5's `tie` fulfills in a more efficient way in Perl 6.

PORTING CAVEATS
===============

Subs versus Methods
-------------------

In Rakudo Perl 6, the special methods of the tieing class, can be implemented as Perl 6 `method`s, or they can be implemented as `our sub`s, both are perfectly acceptable. They can even be mixed, if necessary. But note that if you're depending on subclassing, that you must change the `package` to a `class` to make things work.

Untieing
--------

Because Rakudo Perl 6 does not have the concept of magic that can be added or removed, it is **not** possible to `untie` a variable. Note that the associated `UNTIE` sub/method **will** be called, so that any resources can be freed.

Potentially it would be possible to actually have any subsequent accesses to the tied variable throw an exception: perhaps it will at some point.

Scalar variable tying versus Proxy
----------------------------------

Because tying a scalar in Rakudo Perl 6 **must** be implemented using a `Proxy`, and it is currently not possible to mix in any additional behaviour into a `Proxy`, it is alas impossible to implement `UNTIE` and `DESTROY` for tied scalars at this point in time. Please note that `UNTIE` and `DESTROY` **are** supported for tied arrays and hashes.

Tieing a file handle
--------------------

Tieing a file handle is not yet implemented at this time. Mainly because I don't grok yet how to do that. As usual, patches and Pull Requests are welcome!

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5tie . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

