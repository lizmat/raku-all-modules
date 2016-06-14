# Audio::Fingerprint::Chromaprint

Get audio fingerprint using the chromaprint / AcoustID library

## Synopsis

```perl6

use Audio::Fingerprint::Chromaprint;
use Audio::Sndfile;

my $fp = Audio::Fingerprint::Chromaprint.new;

my $wav = Audio::Sndfile.new(filename => 'some.wav', :r);

$fp.start($wav.samplerate, $wav.channels);

# Read the whole file at once
my ( $data, $frames ) = $wav.read-short($wav.frames, :raw);

# You can feed multiple times
$fp.feed($data, $frames);

# call finish to indicate done feeding
$fp.finish;

say $fp.fingerprint;

```


## Description

This provides a mechanism for obtaining a fingerprint of some audio data
using the [Chromaprint library](https://acoustid.org/chromaprint), you
can use this to identify recorded audio or determine whether two audio
files are the same for instance.

You need several seconds worth of data in order to be able to get a
usable fingerprint, and for comparison of two files you will need to
ensure that you have the same number of samples, ideally you should
fingerprint the entire audio file, but this may be slow if you have
a large file.

Depending on how the Chromaprint library was built, it may or may not
be safe to have multiple instances created at the same time, so it
is probably safest to take care you only have a single instance in
your application.

## Installation

You will need the chromaprint library installed for this to work,
many operating system distributions will have a package that you
can install with appropriate software.  If you do not have a package
available you may be able to build it from the source which can be
found at https://acoustid.org/chromaprint.

Assuming you have a working rakudo Perl 6 installation (and the
chromaprint library,) then you should be able to install the module
with ```panda``` :

	panda install Audio::Fingerprint::Chromaprint

or with ```zef```

	zef install Audio::Fingerprint::Chromaprint

Other installers may become available in the future.

## Support

This is a fairly simple library, but if you find a problem with it
or have a suggestion how it can be improved then please raise a
ticket at https://github.com/jonathanstowe/Audio-Fingerprint-Chromaprint/issues.

## Copyright & Licence

This is free software.

See the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2016

