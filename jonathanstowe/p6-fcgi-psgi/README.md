# FastCGI::NativeCall::PSGI

This is a PSGI interface for [FastCGI::NativeCall](https://github.com/jonathanstowe/p6-fcgi)

[![Build Status](https://travis-ci.org/jonathanstowe/p6-fcgi-psgi.svg?branch=master)](https://travis-ci.org/jonathanstowe/p6-fcgi-psgi)

## Synopsis

Basic usage:

```perl6
use FastCGI::NativeCall::PSGI;

my $psgi = FastCGI::NativeCall::PSGI.new(path => "/tmp/fastcgi.sock", backlog => 32);

sub dispatch-psgi($env) {
    return [ 200, { Content-Type => 'text/html' }, "Hello world" ];
}

$psgi.run(&dispatch-psgi);
```

Using [Bailador](https://github.com/Bailador/Bailador):

```perl6
use FastCGI::NativeCall::PSGI;
use Bailador;

get "/" => sub {
    "Hello world";
}


my $psgi = FastCGI::NativeCall::PSGI.new(path => "/tmp/fastcgi.sock", backlog => 32);
$psgi.run(get-psgi-app());
```

Using [Crust](https://github.com/tokuhirom/p6-Crust):

```perl6
use FastCGI::NativeCall::PSGI;
use Crust::Builder;

my &app = builder {
    mount "/" , sub (%env) {
        start { 200, [Content-Type => "text/html"], ["Hello world"] };
    }
};


my $psgi = FastCGI::NativeCall::PSGI.new(path => "/tmp/fastcgi.sock", backlog => 32);
$psgi.run(&app);
```

A suitable nginx configuration for these can be found in the [examples](examples) directory.

## Description

[FastCGI](https://fastcgi-archives.github.io/) is a protocol that allows
an HTTP server to communicate with a persistent application over a
socket, thus removing the process startup overhead of, say, traditional
CGI applications.  It is supported as standard (or through supporting
modules,) by most common HTTP server software (such as Apache, nginx,
lighthttpd and so forth.)

This module builds on
[FastCGI::NativeCall](https://github.com/jonathanstowe/p6-fcgi) to
provide a PSGI/P6GI/P6W interface for web applications.

Despite being single threaded it can be relatively high performance with
appropriate tuning of the server configuration.

## Installation

You will need an HTTP server that supports FastCGI to be able to use this.

Assuming you have a working Rakudo Perl 6 installation then you should
be able to insall it with *zef*

    zef install FastCGI::NativeCall::PSGI

    # Or from a local clone

    zef install .

## Support

I am probably not the right person to be asking about the configuration
of various server software to use FastCGI, you probably want to consult
the manuals in the first place.

Some parts of the support for the full P6GI/P6W spec may be incomplete
but this should be filled out over time.

In testing with [Siege](https://www.joedog.org/siege-home/) some
frameworks performed remarkably worse than others, if you have a concern
about the performance of your application please try to test with another
host server as it may be the framework rather than this module.

Please send suggests/patches etc to
https://github.com/jonathanstowe/p6-fcgi-psgi/issues


## Copyright and Licence

This is free software. Please see the [LICENSE](LICENSE) file for details.

    Copyright (c) 2015, carlin <cb@viennan.net>
                © 2017, Jonathan Stowe
