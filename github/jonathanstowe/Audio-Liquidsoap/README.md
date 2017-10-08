# Audio::Liquidsoap

Interact with the Liquidsoap telnet interface.

[![Build Status](https://travis-ci.org/jonathanstowe/Audio-Liquidsoap.svg?branch=master)](https://travis-ci.org/jonathanstowe/Audio-Liquidsoap)

## Synopsis

```perl6

use Audio::Liquidsoap;

my $ls = Audio::Liquidsoap.new;

say "Connected to liquidsoap { $ls.version } up since { DateTime.new($ls.uptime) }";


...

```

There are more complete examples in the [Examples Directory](./examples)

## Description

This provides a mechanism to interact with the [Liquidsoap media
toolkit](http://liquidsoap.fm/) and possibly build radio applications
with it.

It provides abstractions to interact with the defined Inputs, Outputs,
Queues, Playlists and Requests to the extent allowed by the "telnet"
interface of ```liquidsoap```.  There is also a generalised mechanism
for sending arbitrary commands to the server, such as those that may
have been provided by the liquidsoap ```server.register``` function.
However it should be borne in mind that you will almost certainly need
to still actually to write some liquidsoap script in order to declare
the things to manipulate. 

Currently this only supports a TCP connection to the liquidsoap command
server as Perl 6 does not currently support Unix domain sockets, so you
may need to use something like ```netcat``` to provide a proxy if you
want to work with an existing installation that provides a server for
Unix domain sockets.

## Installation

You will need to have "liquidsoap"  installed on your system in order to
be able to use this. Some Linux distributions and some versions of FreeBSD
provide it as a package.

If you are on some platform that doesn't provide liquidsoap as a package
then you may be able to install it from source:

	http://liquidsoap.fm/download.html

It's written in OCaml and has lots of dependencies that you are unlikely
to already have but it's doable on most platforms.

The tests assume that you have ```liquidsoap``` installed somewhere in your
path and will run an instance on an unused port so as not to interfere
with some running instance you may already have.  If your ```liquidsoap```
is installed somewhere that is not in your path then you can set the
environment variable ```LIQUIDSOAP``` to the full path of the binary
before running the tests.


Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Audio::Liquidsoap

## Support

Because of the potential complexity that can be achieved in 
custom liquidsoap scripts, this almost certainly doesn't cover
every possibility in the interface, but if you really need
something I have omitted or have other suggestions please raise
an issue at:

https://github.com/jonathanstowe/Audio-Liquidsoap

And I'll see what I can do.

I'm also probably not the best person to ask if you have anything
but the most simple questions about liquidsoap itself, which may
probably be raised via the liquidsoap website.


## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2016, 2017

