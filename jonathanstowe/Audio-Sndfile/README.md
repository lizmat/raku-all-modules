# Audio::Sndfile

Binding to libsndfile ( http://www.mega-nerd.com/libsndfile/ )

[![Build Status](https://travis-ci.org/jonathanstowe/Audio-Sndfile.svg?branch=master)](https://travis-ci.org/jonathanstowe/Audio-Sndfile)

## Description

This library provides a mechanism to read and write audio data files in
various formats by using the API provided by libsndfile.

A full list of the formats it is able to work with can be found at:

http://www.mega-nerd.com/libsndfile/#Features

if you need to work with formats that aren't listed then you will need to
find another library.

The interface presented is slightly simplified with regard to that of
libsndfile and whilst it does nearly everything I need it do, I have opted
to release the most useful functionality early and progressively add
features as it becomes clear how they should be implemented.

The "examples" directory in the repository contains some sample code that
may be useful or indicate how you might achieve a particular task.

The full documentation is available as [Markdown](Documentation.md) or
as POD withing the module file.

## Installation

You will need to have "libsndfile"  installed on your system in order to
be able to use this. Most Linux distributions offer it as a package, though
it is such a common dependency for multimedia applications that you may well
already have it installed.

If you are on some platform that doesn't provide libsndfile as a package
then you may be able to install it from source:

http://www.mega-nerd.com/libsndfile/#Download

I am however unlikely to be able to offer help with installing it this way.

Assuming you have a working perl6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Audio::Sndfile

Although I haven't tested it this should install fine with *zef* or
some equally capable package manager that may come along.

## Support

Suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/Audio-Sndfile/issues

There are several things that I know don't work properly at the time of the
first release:

    * May not work at all or be unstable on 32 bit systems
      ( This is because data that references the number of frames is
        native sized within libsndfile - when I have worked out how to
        do the equivalent of a conditional typedef I'll fix this .)

Also I'd prefer to keep features that aren't directly related to those
provided by libsndfile separate, so if you want to manipulate the data,
play the data to some audio device or stream it for instance you probably
want to consider making a new module.

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2015, 2016
