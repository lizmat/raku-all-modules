# Test::Util::ServerPort 

Get a free server port for testing with

[![Build Status](https://travis-ci.org/jonathanstowe/Test-Util-ServerPort.svg?branch=master)](https://travis-ci.org/jonathanstowe/Test-Util-ServerPort)

## Synopsis

```

use Test::Util::ServerPort;

my $port = get-unused-port();

# .. start some server with the port


```

## Description

This is a utility to help with the testing of TCP server software.

It exports a single subroutine ```get-unused-port``` that will return
a port number in the range 1025 - 65535 (or a specified range
as an argument,) that is free to be used by a listening socket. It
checks by attempting to ```listen``` on a random port on the range
until it finds one that is not already bound.

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Test::Util::ServerPort

This should work equally well with *zef* but I may not have tested it.

## Support

Suggestions and patches that may make it more useful in your software
are welcomed via github at:

https://github.com/jonathanstowe/Test-Util-ServerPort

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution for details.

© Jonathan Stowe 2016, 2017
