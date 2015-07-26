# Audio-Encode-LameMP3
Encode PCM Audio data to MP3 in Perl 6 using a binding to liblame

## Description

This module provides a simple bind to "lame" an MP3 encoding library.

http://lame.sourceforge.net/

With this you can encode PCM data to MP3 at any bitrate or quality
supported by the lame library.

The interface is somewhat simplified in comparison to that of lame
and some of the esoteric or rarely used features may not be supported.

Because marshalling large arrays and buffers between perl space and the
native world may be too slow for some use cases the interface provides
for passing and returning native CArrays (and their sizes) for the use
of other native bindings (e.g. Audio::Sndfile, Audio::Libshout) where 
speed may prove important, which , for me at least, is quite a common
use-case.  The 'p6lame_encode' example demonstrates this way of using
the interface.

For interest the first thing I encoded was:

https://soundcloud.com/rabidgravy/udy-ryu-rabid-gravy-revolutionary-suicide-mix

which is a remix I made of a track by the lovely Aaron Udy.


## Installation

You will need to have "lame"  installed on your system in order to be
able to use this. Most Linux distributions offer it as a package, but
because there are certain patent issues surrounding the MP3 codec some
distributions may either have it in an optional repository or not have
it at all.

If you are on some platform that doesn't provide lame as a package then
you may be able to install it from source:

http://lame.sourceforge.net/

I am however unlikely to be able to offer help with installing it this
way, also bear in mind that if you install a newer version than I have
to test with then this may not work.

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Audio::Encode-LameMP3

Other install mechanisms may be become available in the future.

The tests take a little longer than I would like largely because there's
quite a lot of file I/O involved.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

https://github.com/jonathanstowe/Audio-Encode-LameMP3

I have tested this and found it to work with my installation of libmp3lame
so it should work anywhere else the library is installed, if however
you experience a problem with the encoding, please test with the 'lame'
binary that is installed with libmp3lame before reporting a bug. Obviously
because the actual encoding is done by the native library, I'm not
able to comment on the perceived quality or otherwise of the results.

## Licence

This library only binds to a "lame" installation you may have on your system, any
licensing issues regarding the MP3 codec relate to the implementation of the codec
and I cannot answer questions related to the licensing of that library.

Please see the LICENCE file in the distribution regarding the licence for this library module.

(C) Jonathan Stowe 2015
