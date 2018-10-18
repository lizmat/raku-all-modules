# FastCGI::NativeCall::Async

An asynchronous wrapper for [FastCGI::NativeCall](https://github.com/jonathanstowe/p6-fcgi)

[![Build Status](https://travis-ci.org/jonathanstowe/FastCGI-NativeCall-Async.svg?branch=master)](https://travis-ci.org/jonathanstowe/FastCGI-NativeCall-Async)

## Synopsis

```perl6
use FastCGI::NativeCall::Async;

my $fna = FastCGI::NativeCall::Async.new(path => "/tmp/fastcgi.sock", backlog => 32 );

my $count = 0;

react {
    whenever $fna -> $fcgi {
	    say $fcgi.env;
        $fcgi.Print("Content-Type: text/html\r\n\r\n{++$count}");
    }

}
```

## Description

The rationale behind this module is to help
[FastCGI::NativeCall](https://github.com/jonathanstowe/p6-fcgi)
play nicely in a larger program by managing the blocking accept loop as
a Supply that can for instance be used in a ```react``` block as above.
It doesn't actually allow more than one FastCGI request to be processed at
once for the same URI as the protocol itself precludes that.  However it
does allow more than one FastCGI handler to be present in the same Perl
6 program, potentially sharing data and other resources.

## Installation

You will need a working HTTP server that can handle FastCGI to be able to
use this properly.

Assuming you have a working Rakudo Perl installation you should be able to
install this with *zef* :

     zef install FastCGI::NativeCall::Async

     # Or from a local clone 

     zef install .

## Support

This module itself is fairly simple, but does depend on both other modules and the configuration of
of your HTTP Server.

Please send any suggestions/patches etc to https://github.com/jonathanstowe/FastCGI-NativeCall-Async/issues

I'd be interested in working configurations for various HTTP servers.

## Licence & Copyright

This is free software see the [LICENCE](LICENCE) file in the distribution.

© 2017 Jonathan Stowe
