# CheckSocket

A very simple Perl 6 function to test if a TCP socket is listening on
a given address.

## Description

This module provides a very simple mechanism to determine whether
something is listening on a TCP socket at the given port and address.
This is primarly for the convenience of testing where there may be a
dependency on an external network service.  For example:

     use Test;
     use CheckSocket;

     if not check-socket(80, "localhost") {
	      skip-all "no web server";
         exit;
     }

## Installation

You can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install CheckSocket

I haven't tested with "zef" but I see no reason why it shouldn't work.

## Support

Suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/CheckSocket

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015, 2016
