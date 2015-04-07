# EventEmitter

Perl6 roles to sugar events through Supplies

## Description

This provides a set of convenience roles that allow an object to have
a simple mechanism to have "events" - this is merely a thin layer over
the core Supply class.

The two roles it currenty provides are:

	* EventEmitter::Node - events like node.js
	* EventEmitter::Typed - use "event objects"

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

    # Remove installation

    panda install EventEmitter

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/EventEmitter

I'm not able to test on a wide variety of platforms so any help there would be 
appreciated.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
