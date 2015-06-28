# LibraryCheck

Determine whether a shared library is available to be loaded by Perl 6

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

     if !library-exists('libsndfile') {
         die "Cannot load libsndfile";
     }

The implementation is somewhat of a hack currently and definitely shouldn't
be taken as an example of nice Perl 6 code.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install LibraryCheck

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/LibraryCheck

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
