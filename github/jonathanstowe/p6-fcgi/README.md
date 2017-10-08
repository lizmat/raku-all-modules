# FastCGI::NativeCall #

This is an implementation of FastCGI for Perl 6 using NativeCall

[![Build Status](https://travis-ci.org/jonathanstowe/p6-fcgi.svg?branch=master)](https://travis-ci.org/jonathanstowe/p6-fcgi)

## Synopsis

```perl6
use FastCGI::NativeCall;

my $fcgi = FastCGI::NativeCall.new(path => "/tmp/fastcgi.sock", backlog => 32 );

my $count = 0;

while $fcgi.accept() {
	say $fcgi.env;
    $fcgi.header(Content-Type => "text/html");
    $fcgi.Print("{ ++$count }");
}
```
There is an example [nginx](http://nginx.org/) configuration in the [examples](examples) directory.

## Description

[FastCGI](https://fastcgi-archives.github.io/) is a protocol that allows an HTTP server to communicate
with a persistent application over a socket, thus removing the process startup overhead of, say, traditional
CGI applications.  It is supported as standard (or through supporting modules,) by most common HTTP server
software (such as Apache, nginx, lighthttpd and so forth.)

This module provides a simple mechanism to create FastCGI server applications in Perl 6.

The FastCGI servers are single threaded, but with good support from the front end server and tuning of the
configuration it can be quite efficient.

## Installation

In order to use this properly you will need some front end server that supports FastCGI using unix domain sockets.

Assuming you have a working Rakudo Perl 6 installation you should be able to install this with *zef*:

	zef install FastCGI::NativeCall

	# Or from a local clone of the distribution

	zef install .

## Support

I'm probably not the right person to ask about configuring various HTTP servers for FastCGI. Though I'd
be interested in sample configurations if anyone wants to provide any.

Also the tests are a bit rubbish, I haven't worked out how to mock an HTTP server that does FastCGI yet.

If you have any suggestions/bugs etc please report them at https://github.com/jonathanstowe/p6-fcgi/issues

## Licence and Copyright

This is free software please see the [LICENSE](LICENSE) file in the distribution.

© carbin 2015
© Jonathan Stowe 2016, 2017

The FastCGI C application library is distributed under its own license.
See "ext/LICENSE.TERMS" for the license.








