# Audio::Convert::Samplerate

Convert the samplerate of PCM audio data using libsamplerate (AKA "Secret Rabbit Code".)

## Description

This provides a mechanism for doing sample rate conversion of PCM audio
data using libsamplerate (http://www.mega-nerd.com/libsamplerate/)
the implementation of which is both fairly quick and accurate.

The interface is fairly simple, providing methods to work with native
C arrays where the raw speed is important as well as perl arrays where
further processing is required on the data.

The native library is designed to work only with 32 bit floating point
samples so working with other sample types requires some conversion
and a subsequent small loss of efficiency (although the int and short
to float conversions are done in C code and so are reasonably quick.)
There is no support for 64 bit int (long) or float (double) data.


## Installation

You will need to have "libsamplerate"  installed on your system in order to
be able to use this. Most Linux distributions offer it as a package, though
it is such a common dependency for multimedia applications that you may well
already have it installed.

If you are on some platform that doesn't provide libsamplerate as a package
then you may be able to install it from source:

http://www.mega-nerd.com/libsamplerate/download.html

I am however unlikely to be able to offer help with installing it this way.

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

    panda install Audio::Convert::Samplerate

Other install mechanisms may be become available in the future.

## Support

However suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/Audio-Convert-Samplerate

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015, 2016
