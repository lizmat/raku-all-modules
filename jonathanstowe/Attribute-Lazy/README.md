# Attribute::Lazy 

Lazy attribute initialisation for Perl 6 classes

[![Build Status](https://travis-ci.org/jonathanstowe/Attribute-Lazy.svg?branch=master)](https://travis-ci.org/jonathanstowe/Attribute-Lazy)

## Synopsis

```perl6

use Attribute::Lazy;

class Foo {
    has $.foo will lazy { "zub" };
}

```

## Description

This is based on an experimental trait that was briefly in the Rakudo core.

Attribute::Lazy provides a single *trait* *will lazy* that will allow
an attribute with a public accessor (that is one defined with the "." twigil,)
to be initialised *the first time it is accessed* by the result of the supplied
block.  This might be useful if the value may not be used and may be expensive
to calculate (or various other reasons that haven't been thought of.)

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Attribute::Lazy

Or *zef*:

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Attribute::Lazy

Other install mechanisms may be become available in the future.

## Support

Suggestions/patches are welcomed via github at https://github.com/jonathanstowe/Attribute-Lazy

## Licence

Please see the LICENCE file in the distribution

© Rakudo Contributors 2015
© Jonathan Stowe 2016

