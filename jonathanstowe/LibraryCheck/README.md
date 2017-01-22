# LibraryCheck

Determine whether a shared library is available to be loaded by Perl 6

[![Build Status](https://travis-ci.org/jonathanstowe/LibraryCheck.svg?branch=master)](https://travis-ci.org/jonathanstowe/LibraryCheck)

## Synopsis

```perl6

     use LibraryCheck;

     if !library-exists('sndfile', v1) {
         die "Cannot load sndfile";
     }

```

## Description

This module provides a mechanism that will determine whether a named
shared library is available and can be used by NativeCall.

It exports a single function 'library-exists' that returns a boolean to
indicate whether the named shared library can be loaded and used.

This can be used in a builder to determine whether a module has a chance
of working (and possibly aborting the build,) or in tests to cause the
tests that may rely on a shared library to be skipped, but other use-cases
are possible.

     use LibraryCheck;

     if !library-exists('sndfile', v1) {
         die "Cannot load sndfile";
     }

The case above can be more simply written as:

     library-check('sndfile',v1, :exception);

Which will throw an ```X::NoLibrary``` exception rather than return False.

The implementation is somewhat of a hack currently and definitely shouldn't
be taken as an example of nice Perl 6 code.

## Installation

Assuming you have a working Rakudo perl6 installation you should be able to
install this with either *zef* or *panda* :

    # From the source directory
   
    panda install .

    # or

    zef install .

    # Remote installation

    panda install LibraryCheck

    # or

    zef install LibraryCheck

Other install mechanisms may be become available in the future.

## Support

Suggestions/patches are welcomed via github at
https://github.com/jonathanstowe/LibraryCheck/issues

I'd be particularly interested in having it work properly on all the
platforms that rakudo will work on.

## Licence

Please see the LICENCE file in the distribution

© Jonathan Stowe 2015, 2016
