# Task-Noise

META package to install all the noise related modules

## Description

This is a convenience to install the following modules which
are all of those known to the [Perl 6 Noise Gang](http://perl6.noisegang.com)
that can be used to make or process noise of some kind:

* [ABC](http://modules.perl6.org/dist/ABC)
* [Music::Helpers](http://modules.perl6.org/dist/Music::Helpers)
* [Audio::Taglib::Simple](http://modules.perl6.org/dist/Audio::Taglib::Simple)
* [Audio::Sndfile](http://modules.perl6.org/dist/Audio::Sndfile)
* [Audio::Libshout](http://modules.perl6.org/dist/Audio::Libshout)
* [Audio::Encode::LameMP3](http://modules.perl6.org/dist/Audio::Encode::LameMP3)
* [Audio::Convert::Samplerate](http://modules.perl6.org/dist/Audio::Convert::Samplerate)
* [Audio::Silan](http://modules.perl6.org/dist/Audio::Silan)
* [Audio::Liquidsoap](http://modules.perl6.org/dist/Audio::Liquidsoap)
* [Audio::Playlist::JSPF](http://modules.perl6.org/dist/Audio::Playlist::JSPF)
* [Audio::Hydrogen](http://modules.perl6.org/dist/Audio::Hydrogen)
* [Audio::PortAudio](http://modules.perl6.org/dist/Audio::PortAudio)
* [Audio::PortMIDI](http://modules.perl6.org/dist/Audio::PortMIDI)
* [Audio::Icecast](http://modules.perl6.org/dist/Audio::Icecast)
* [EuclideanRhythm](http://modules.perl6.org/dist/EuclideanRhythm)
* [Audio::MIDI::Note](http://modules.perl6.org/dist/Audio::MIDI::Note)
* [Audio::OggVorbis](http://modules.perl6.org/dist/Audio::OggVorbis)

There's absolutely no guarantee that all of these will be useful to you, but
it should give you an idea of some of the things that you can do with
sounds with Perl 6.

## Installation

Many of the modules that will be installed will have external dependencies that
won't be installed for you, they may simply fail the tests because of a missing
shared library or binary, so you probably want to consult the individual README
files of each module if you experience problems.

If you have a working Rakudo Perl 6 installation then you should be able to do:

	zef install Task::Noise

depending on your preference.

## Support

If you have a problem with one of the modules that this installs please try
and contact the author using the mechanism they may have indicated in the
documentation of the module.

If of course you have any suggestions or additions for the list of modules
included please raise a ticket at https://github.com/Perl6-Noise-Gang/Task-Noise/issues

## Copyright

The copyright of the individual modules will be as indicated by the authors.

© The Perl 6 Noise Gang 2016
