# Linux::Fuser
Discover which process has a file open, in pure Perl 6.

## Description

This is based on the similarly named module for Perl 5 available from CPAN.

Linux::Fuser provides a mechanism to determine which processes have a specified
file open in a similar manner to the system utility *fuser*. There is an example
program *p6fuser* in the *examples* directory which provides a Perl 6 implementation
of that command.

Because this relies on the layout of the /proc filesystem specific to the Linux
kernel it almost certainly will not work on any other operating system, though I
would be delighted to hear about any where it does work.

## Installation

Assuming you have a working perl6 installation you should be able to install this
with *ufo* :

   ufo
   make test
   make install

*ufo* can be installed with *panda* for rakudo:

   panda install ufo

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that Perl 6 reaches
an official release.  However suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/p6-Linux-Fuser

I'm not able to test on a wide variety of platforms so any help there would be 
appreciated.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
