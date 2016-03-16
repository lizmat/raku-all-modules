# CheckSocket

A very simple Perl 6 function to test if a TCP socket is listening on a given address.

## Description

This module provides a very simple mechanism to determine whether something is listening on
a TCP socket at the given port and address.  This is primarly for the convenience of testing
where there may be a dependency on an external network service.  For example:

     use Test;
     use CheckSocket;

     if not check-socket(80, "localhost") {
	      skip-all "no web server";
         exit;
     }

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

    panda install CheckSocket

Other install mechanisms may be become available in the future.

## Support

However suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/CheckSocket

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015, 2016
