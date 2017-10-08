NAME
====

Audio::Icecast - adminstrative interface to icecast

SYNOPSIS
========

    use Audio::Icecast;

    # Using the default configuration

    my $icecast = Audio::Icecast.new;

    for $icecast.stats.source -> $source {
        say "listeners for { $source.mount }";
        for $icecast.listeners($source) -> $listener {
            say "\t",$listener.ip;
        }
    }

See also the the `example` directory.

DESCRIPTION
===========

This provides an interface to the admin API of a running  [icecast](http://www.icecast.org) audio streaming server.

The API itself is quite thin as the icecast server doesn't do much more than stream audio from a source quite efficiently.

Some features such as static mounts and alternative authentication mechanisms can only be enabled via the configuration file and not dynamically, if you want more control over the streams at runtime then you might consider using a streaming middleware such as [liquidsoap](http://liquidsoap.fm/) in conjunction with your icecast server.

You probably should at least familiarise yourself with the [icecast docummentation](http://www.icecast.org/docs/icecast-2.4.1/) before making serious use of this module.

METHODS
=======

Where given as a string below a mount name must be given as found in the `mount` attribute of [Audio::Icecast::Source](#Audio::Icecast::Source), that is prefixed with a '/' (e.g. '/mount'.)

method new
----------

    method new(Str :$host = 'localhost', Int :$port = 8000, Bool :$secure = False, Str :$user = 'admin', Str :$password = 'hackme')

The constructor for the class supplies defaults that will work with a stock configuration on the local machine, this probably isn't what you want, because at the very least you changed the password right? If you are unsure of the appropriate values then you may need to look at the `icecast.xml` which will typically be in `/etc` or `/usr/local/etc`.

The `:secure` flag is provided to allow an https connection to the server but I am not actually aware of any possible configuration of icecast which make this necessary.

method stats
------------

    method stats() returns Stats

This returns a [Audio::Icecast::Stats](#Audio::Icecast::Stats) object that reflects the current statistics for the icecast server.

method listeners
----------------

    multi method listeners(Source $source)
    multi method listeners(Str $mount)

This returns a list of [Audio::Icecast::Listener](#Audio::Icecast::Listener) objects reflecting the listeners of the supplied mount, which can be supplied as either a string or a [Audio::Icecast::Source](#Audio::Icecast::Source) object.

method update-metadata
----------------------

    multi method update-metadata(Source $source, Str $meta)
    multi method update-metadata(Str $mount, Str $meta)

This updates the stream metadata for the supplied mount which can either be supplied as a [Audio::Icecast::Source](#Audio::Icecast::Source) object or a string.

method set-fallback
-------------------

    multi method set-fallback(Source $source, Source $fallback)
    multi method set-fallback(Str $mount, Str $fallback)

This sets a fallback on the specified mount to another mount, that is if the source for the mount disconnects then the clients will be moved automatically to the fallback mount. The source and fallback can be supplied as strings or [Audio::Icecast::Source](#Audio::Icecast::Source) objects.

method move-clients
-------------------

    multi method move-clients(Source $source, Source $destination)
    multi method move-clients(Str $mount, Str $destination)

This will move the clients connected to the supplied mount to a different one, which must have an active source. Both source and destination can be supplied as strings or as [Audio::Icecast::Source](#Audio::Icecast::Source) objects.

method kill-client
------------------

    multi method kill-client(Source $source, Listener $client)
    multi method kill-client(Str $mount, Str() $id)

This disconnects the client which can either be specified as a [Audio::Icecast::Listener](#Audio::Icecast::Listener) object or a string ID, on the supplied mount.

method kill-source
------------------

    multi method kill-source(Source $source)
    multi method kill-source(Str $mount)

This disconnects the source client supplying the specified mount, the mount can be supplied as the string name of the mount or as a [Audio::Icecast::Source](#Audio::Icecast::Source) object.

Audio::Icecast::Stats
=====================

Objects of this type represent the statistics for the running icecast server, some of the attributes are derived directly from the configuration file of the server and won't change.

mount
-----

This is the name of the "mount", it will always be prefixed with a '/', this is the local part of the URL on which listeners will be able to connect to the resulting stream.

audio-info
----------

This is a string describing the properties of the stream,  comprised of `bitrate`, `channels` and `samplerate`

bitrate
-------

The streaming bitrate of the stream in Kilobits per second.

channels
--------

The number of audio channels in the stream, this should only over be 1 or two.

genre
-----

The text genre as supplied by the source client.

listener-peak
-------------

The maximum number of concurrent listeners of the stream since it was started.

listeners
---------

The current number of connected listeners.

listen-url
----------

This is the public URL of the stream, derived from the configured host name of the server and the mount name.

max-listeners
-------------

This is the maximum permitted number of concurrent listeners allowed on the stream, if it is "unlimited" it will be a very big number (beyond the capability of icecast to serve.)

public
------

A boolean indicating whether the stream should be shown in a directory of streams. This is typically supplied by the source client.

samplerate
----------

This is the samplerate derived from the source stream. It is expressed in "frames per second", e.g. 44100

server-description
------------------

A description of the stream which will typically be supplied by the source client.

server-name
-----------

The "name" of the stream which will typically be supplied by the source client.

server-type
-----------

The media type of the stream as inferred from the source stream, e.g. "audio/mpeg", "audio/aac".

slow-listeners
--------------

The number of listeners on the stream that are determined to be "slow", that is to say they are being sent data that is more than a single buffer behind what the source has  sent. This may have an impact when the stream is shut down or the client moved to another mount.

source-ip
---------

This is the peer address of the source client.

stream-start
------------

This is the datetime at which the source started, usually the point when the source client connected, however it may be different for a "static" mount defined in the icecast config.

total-bytes-read
----------------

The total number of bytes received from the source client.

total-bytes-sent
----------------

The total number of bytes sent to the listeners of this mount.

user-agent
----------

The User-Agent header provided by the source client.

Audio::Icecast::Listener
========================

This describes a consumer of a stream.

id
--

This is icecast's internal identifier for the client connection. It is the value required by `kill-client`. 

ip
--

The peer address of the client.

user-agent
----------

The "User-Agent" header presented by the client software.

connected
---------

A Duration object representing the number of seconds the client has been connected.
