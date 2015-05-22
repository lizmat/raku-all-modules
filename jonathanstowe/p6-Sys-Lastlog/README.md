# Sys::Lastlog

Get access to the last login information on Unix-like systems

## Description

This module is designed to provided an Object Oriented API to the lastlog
file found on many Unix-like systems.  Some systems do not have this file
so this module will not be of much use on those systems.


## Installation

Currently there is no dedicated test to determine whether your platform is
supported, the unit tests will simply fail horribly.

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

    panda install Sys::Lastlog

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Sys-Lastlog

