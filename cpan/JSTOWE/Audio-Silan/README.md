# Audio::Silan

Audio silence detection using silan (https://github.com/x42/silan)

[![Build Status](https://travis-ci.org/jonathanstowe/Audio-Silan.svg?branch=master)](https://travis-ci.org/jonathanstowe/Audio-Silan)

## Synopsis

```perl6

use Audio::Silan;

my $silan = Audio::Silan.new;

my $promise = $silan.find-boundaries($some-audio-file);

await $promise.then(-> $i { say "Start : { $i.start } End: { $i.end }" });

```

## Description

This module provides a mechanism to use [Silan](https://github.com/x42/silan)
to detect the silence at the beginning and end of an audio file (which are
sometimes described as cue in and cue out points.)

It allows the setting of the silence threshold and "hold off" (that is the
minimum length of silence required before it is considered the end of the
audio.)  For certain material these values may need adjustment in order to
provide accurate output.

Because the detection may take some time for larger files, this takes
place asynchronously: the method ```find-boundaries``` returns a
[Promise](http://doc.perl6.org/type/Promise) which will be kept with
the result of the detection (or broken if the detection failed.)


## Installation

In order for this to work you will need a working installtion of 
[Silan](https://github.com/x42/silan), this is often available as a package
on Unix-like systems and you can use the appropriate package manager to
install it.  If it is not available as a package then it should be possible
to install it from source.

Assuming you have a working Rakudo perl6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Audio::Silan

Other install mechanisms may be become available in the future.

## Support

Suggestions/patches are welcomed via github at:

   https://github.com/jonathanstowe/Audio-Silan/issues

It should be borne in mind before reporting an issue that this depends
on the behaviour of silan itself and that is likely that any mis-reporting
of the audio bounds is a result of silan itself or the parameters that are
being used,  I do know that version 0.3.2 of silan (which is frequently
distributed with OS distributions,) may mis-detect for longer MP3 files
(for example a 2 hour MP3 file may be detected as "ending" around the hour
mark,) if this causes a problem to you then you should try upgrading the
silan.  [This issue](https://github.com/x42/silan/issues/3) may also
suggest that for certain types of file, the underlying libraries may also
have an impact.

## Licence

This is free software.

Please see the LICENCE file in the distribution

© Jonathan Stowe 2015, 2016, 2017, 2019
