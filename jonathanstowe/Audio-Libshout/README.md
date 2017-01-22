# Audio::Libshout

Perl 6 binding to libshout - provide icecast/streaming client

[![Build Status](https://travis-ci.org/jonathanstowe/Audio-Libshout.svg?branch=master)](https://travis-ci.org/jonathanstowe/Audio-Libshout)

## Description

This provides a source client to stream to an icecast server.  It can
stream Ogg/Vorbis or MP3 data but doesn't provide any transcoding so the
data will need to be provided from an appropriate source in the required
encoding. This has been developed against version 2.2.2 of libshout,
it is possible later versions may provide support for other encodings.

The API is somewhat simplified in comparison to libshout but provides
an asynchronous mechanism whereby data can be fed as quickly as it is
obtained to a worker thread via a channel so the client doesn't have
to worry about the timing and synchronisation issues, though the lower
level send and sync methods are available if your application requires
a different scheme.

In testing this proved quite capable of streaming a 320kb/s MP3 read from
a file to an icecast server on the local network, though of course network
conditions may limit the rate that will work well to remote servers.

The "examples" directory in the distribution contains a simple streaming
source client that will allow you to send an Ogg or MP3 file to an
icecast server.

If you're curious the first thing that I streamed using this library was

https://www.mixcloud.com/mikestern-awakening/mike-stern-guest-mix-for-technotic-eire-radio-show/

Mike's a great DJ, great DJs and producers make making software
worthwhile :)

The full documentation is available as [markdown](Documentation.md) or embedded POD.

## Installation

You will need to have "libshout"  installed on your system in order to
be able to use this. Most Linux distributions offer it as a package.


If you are on some platform that doesn't provide libshout as a package
then you may be able to install it from source:

https://github.com/xiph/Icecast-libshout

I am however unlikely to be able to offer help with installing it this way, also bear in mind that
if you install a newer version than I have to test with then this may not work.

In order to perform some of the tests you will need to have a working Icecast server available,
these tests will be skipped if one isn't found.  The tests use some default values for the server
parameters that can be over-written by some environment variables:

   * SHOUT_TEST_HOST - the host to connect to. The default is 'localhost'
   * SHOUT_TEST_PORT - the port to connect to. The default is 8000.
   * SHOUT_TEST_USER - the user to authenticate as. The default is 'source'.
   * SHOUT_TEST_PASS - the password to authenticate with.  The default is 'hackme' but you changed that right?
   * SHOUT_TEST_MOUNT - the mount point on the server to use.  The default is '/shout_test'

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Audio::Libshout

This should work equally well with *zef* but I haven't tested it.

## Support

Suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/Audio-Libshout

I have tested this and found it to work with my installation of icecast,
so it should work anywhere else, if however you experience a problem
with streaming please test with another source client such as ices or
darkice before reporting a bug as I am unlikely to be able to help you
with your streaming configuration.

## Licence

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017
