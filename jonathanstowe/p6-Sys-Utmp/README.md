# Sys::Utmp

Perl 6 access to Utmp entries on Unix-like systems.

## Description

Sys::Utmp provides access to the Unix user accounting data that may be
described in the utmp(5) manpage.  Briefly it records each logged in
user (and some other data regarding the OS lifetime.)

It will prefer to use the getutent() function from the system C library
if it is available but will attempt to provide its own if the OS doesn't
have that. Because the implementation of getutent() differs between
various OS and the C part of this module needs to provide a consistent
interface to Perl it may not represent all the data that is available on
a particular system, similarly there may be documented attributes that
are not captured on some OS.

## Installation

Because the various Unix-like systems have varying implementations of the
utmp facility this uses a small shared library written in C to provide a
consistent interface to the Perl library, this means that you will require
a working C compiler environment to be able to install this module.

It is entirely possible that the assumptions that I have made in the C
part aren't correct for your system and that this will not install or
work properly, if this is the case please see the "Support" section below.

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

    panda install Sys::Utmp

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Sys-Utmp

I'm not able to test on a wide variety of platforms so any help there would be 
appreciated. Also the assumptions in the C library are based on those used
in the XS part of the similarly named Perl 5 module which was written when
I had access to different systems, but time moves on and operating systems
change and some of this could be completely incorrect for some systems where
it previously worked.  So if you find that this doesn't compile or work
properly on your system and you can work out why the patches will be most
welcome.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
