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

	# or

	use Test;
	use CheckSocket;

	# Start some socket server concurrently
	if wait-socket(80, "localhost") {
		# do some tests
	}
	else {
		skip-all "server didn't start in time";
	}

## Installation

You can install directly with "zef":

    # From the source directory
   
    zef install .

    # Remote installation

    zef install CheckSocket

## Support

Suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/CheckSocket/issues

## Licence

Please see the LICENCE file in the distribution

© Jonathan Stowe 2015, 2016, 2017, 2019
