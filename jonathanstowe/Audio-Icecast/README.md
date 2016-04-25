# Audio::Icecast

Administrative helpers for an icecast server

## Synopsis

```perl6
use Audio::Icecast;

# Using the default configuration

my $icecast = Audio::Icecast.new;

for $icecast.stats.source -> $source {
    say "listeners for { $source.mount }";
    for $icecast.listeners($source) -> $listener {
        say "\t",$listener.ip;
    }
}
```

## Description

This provides a simple interface to the admin interface of an icecast
server.  You can get the statistics, information about the mount points
and do most of the things that you can do through the web UI.

The API itself is quite thin as the icecast server doesn't do much more
than stream audio from a source quite efficiently.

Some features such as static mounts and alternative authentication
mechanisms can only be enabled via the configuration file and
not dynamically, if you want more control over the streams at
runtime then you might consider using a streaming middleware such as
[liquidsoap](http://liquidsoap.fm/) in conjunction with your icecast
server.

You probably should at least familiarise yourself with the [icecast
documentation](http://www.icecast.org/docs/icecast-2.4.1/) before making
serious use of this module.

## Installation

You can install this module using ```panda``` :

    panda install Audio::Icecast

Or if you have the source code locally:

    panda install .

I haven't tested with "zef" but I see no reason why it shouldn't
work.

## Support

This isn't very complicated but the interactions with the server are
quite difficult to test without introducing a bunch more dependencies.
You'll have to take my word for it that I tested against a local
icecast server with actual sources and clients :)

Anyhow if you have any suggestions or feedback feel free to post them
at https://github.com/jonathanstowe/Audio-Icecast/issues or even better
send a pull request.

## License and copyright

This is free software, please see the LICENSE file in the distribution.

	© Jonathan Stowe 2016

