# NAME

Audio::Taglib::Simple - Read, write ID3 and other audio metadata with TagLib

# SYNOPSIS

```perl6
my $taglib = Audio::Taglib::Simple.new("awesome.mp3");

# read a tag
say "artist: ", $taglib.artist;

# edit a tag
$taglib.artist = "Awesome Band";
$taglib.save;

# free memory when you're done
$taglib.free;
```

See also examples/taglib.p6

# DESCRIPTION

This module uses NativeCall to provide bindings to TagLib's C API. The C API is
the "simple" API, which only provides commonly used fields that are abstracted
over all file types.

TagLib supports many audio and tag formats. Audio formats include MP3, MPC,
FLAC, MP4, ASF, AIFF, WAV, TrueAudio, WavPack, Ogg FLAC, Ogg Vorbis, Speex and
Opus file formats. Tag formats include ID3v1, ID3v2, APE, FLAC, Xiph,
iTunes-style MP4 and WMA. See their website for an exhaustive list.

TagLib is nice and fast. The example script runs on a directory of 501 files
(499 are MP3, 2 are non-audio) in around 4 seconds.

# METHODS

## new(Str|IO $file)

Prepares to read the provided file. Dies if the file does not exist or if
TagLib cannot parse it. TagLib attempts to guess the file type here.

## free

Frees the internal data used by TagLib.

## file returns IO

Readonly accessor to the file variable passed in.

## artist() returns Str

Returns the artist of the song.

## album() returns Str

Returns the name of the album associated with the song.

## title() returns Str

Returns the title of the song.

## comment() returns Str

A generic comment field.

## genre() returns Str

A string describing the genre.

## year() returns Int

Returns the year associated with the song as an integer (e.g. 2004) or 0 if not
present.

## track() returns Int

Returns the track number of this song as an integer (e.g. 12) or 0 if not
present.

## save() returns Bool

Call save after assigning to one or more tag attributes (listed above) to write
out the changes.

## length() returns Duration

Returns the length of the file as a Duration. TagLib provides it as an integer.
Not editable.

## bitrate() returns Int

Returns the bit rate of the file as an Int in kb/s. Example: 128. Not editable.

## samplerate() returns Int

Returns the sample rate of the file as an Int in Hz. Example: 44100. Not
editable.

## channels() returns Int

Returns the number of channels present in the file as an Int. Example: 2. Not
editable.

# EXCEPTIONS

## X::InvalidAudioFile

The constructor may raise exceptions if the file does not exist or does not
appear to be audio that TagLib can parse.

### file

The file that is invalid.

### text

The specific error text.

# CAVEATS

- TagLib will start claiming some files are not valid after a
  certain amount of objects are creating them without freeing them.
- TagLib prints some warnings to STDERR directly.
- All fields are read from the metadata, and corrupted files can often have
  incorrect values for length. TagLib does not actually parse the music stream
  to find this out.
- Tags are read at object initialization time. This means that if some other
  process modifies the tags on the music file, you won't see changes unless you
  create a new object.

# REQUIREMENTS

- Rakudo Perl 6 2014.11 or above. Tested primarily on MoarVM.
- NativeCall (included in Rakudo 2015.02 and above)

# TODO

See [TODO](TODO).

# SEE ALSO

[TagLib website](http://taglib.github.io)

[tag\_c.h from the TagLib project](https://github.com/taglib/taglib/blob/master/bindings/c/tag_c.h)

