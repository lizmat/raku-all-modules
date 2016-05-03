NAME
====

Audio::Sndfile - read/write audio data via libsndfile

SYNOPSIS
========

        # Convert file to 32 bit float WAV

        use Audio::Sndfile;

        my $in = Audio::Sndfile.new(filename => "t/data/cw_glitch_noise15.wav", :r);

        my $out-format = Audio::Sndfile::Info::WAV +| Audio::Sndfile::Info::FLOAT;

        my $out = Audio::Sndfile.new(filename   => "out.wav", :w,
                                    channels   => $in.channels,
                                    samplerate => $in.samplerate,
                                    format     => $out-format);

        loop {
	        my @in-frames = $in.read-float(1024);
            $out.write-float(@in-frames);
            last if ( @in-frames / $in.channels ) != 1024;
        }

        $in.close;
        $out.close;

Other examples are available in the "examples" sub-directory of the repository.

DESCRIPTION
===========

This library provides a mechanism to read and write audio data files in various formats by using the API provided by libsndfile.

A full list of the formats it is able to work with can be found at:

http://www.mega-nerd.com/libsndfile/#Features

if you need to work with formats that aren't listed then you will need to find another library.

The interface presented is slightly simplified with regard to that of libsndfile and whilst it does nearly everything I need it do, I have opted to release the most useful functionality early and progressively add features as it becomes clear how they should be implemented.

As of the first release, the methods provided for writing audio data do not constrain the items to the range expected by the method. If out of range data is supplied wrapping will occur which may lead to unexpected results.

### FRAMES vs ITEMS

In the description of the [methods](#METHODS) below a 'frame' refers to one or more items ( that is the number of channels in the audio data.) The frame data is interleaved per channel consecutively and must always have a number of items that is a multiple of the number of channels. The read methods will always return a number of items that is the multiple of number of channels - thus you can determine if you got the number back that you requested with something like:

    @frames.elems == ( $num-channels * $frames-requested)

The write methods will throw an exception if supplied with an array that isn't some multiple of the number of channels and will always return the number of 'frames' written.

There are no methods provided for interleaving or de-interleaving frame data as Perl's list methods (e.g. `zip` or `rotor`) are perfect for this task.

METHODS
-------

### new

    method new(Audio::Sndfile:U: Str :$filename!, :r)

The `:r` adverb opens the specified file for reading. If the file can't be opened or there is some other problem with it (such as it not being a supported format,) then an exception will be thrown.

    method new(Audio::Sndfile:U: Str :$filename!, :w, Audio::Sndfile::Info :$info) 
    method new(Audio::Sndfile:U: Str :$filename!, :w, *%info)

The `:w` adverb opens the specified file for writing. It requires either an existing valid [Audio::Sndfile::Info](Audio::Sndfile::Info) supplied as the `info` named parameter, or attributes that will be passed to the constructor of [Audio::Sndfile::Info](Audio::Sndfile::Info). If the file cannot be opened for some reason or the resulting [Audio::Sndfile::Info](Audio::Sndfile::Info) is incomplete or invalid an exception will be thrown.

The info requires the attributes `channels`, `format`, `samplerate`. If copying or converting an existing file opened for reading the [clone-info](#clone-info) method can be used to obtain a valid [Audio::Sndfile::Info](Audio::Sndfile::Info).

### info

This is an accessor to the [Audio::Sndfile::Info](Audio::Sndfile::Info) for the opened file. It is read-only as it doesn't make sense to change the info after the file has been opened.

There are several accessors delegated to this object:

  * format 

The format of the file formed by the bitwise or of `type`, `sub-type` and `endian`

  * channels 

The number of channels in the file.

  * samplerate 

The sample rate of the file as an Int (e.g. 44100, 48000).

  * frames 

The number of frames in the file. This only makes sense when the file is opened for reading.

  * sections 

  * seekable 

A Bool indicating whether the open file is seekable, this will be True for most regular files and False for special files such as a pipe, however as there currently isn't any easy way to open other than a regular file this may not be useful.

  * type 

A value of the enum [Audio::Sndfile::Info::Format](Audio::Sndfile::Info::Format) indicating the major format of the file (e.g. WAV,) this is bitwise or-ed with the `sub-type` and `endian` to create `format` (which is what is used by the underlying library functions.)

  * sub-type 

A value of the enum [Audio::Sndfile::Info::Subformat](Audio::Sndfile::Info::Subformat) indicating the minor format or sample encoding of the file (e.g PCM_16, FLOAT, ) this is bitwise or-ed with the `type` and `endian` to create `format`

  * endian 

A value of the enum [Audio::Sndfile::Info::End](Audio::Sndfile::Info::End) that indicate the endian-ness of the sample data. This is bitwise or-ed with `type` and `sub-type` to provide `format`.

  * duration

A [Duration](Duration) object that describes the duration of the file in (possibly fractional) seconds. This probably only makes sense for files opened for reading.

### library-version

    method library-version(Audio::Sndfile:D: ) returns Str

Returns a string representation of the version reported by libsndfile.

### close 

    method close(Audio::Sndfile:D:) returns Int

This closes the file stream for the opened file. Attempting to write or read the object after this has been called is an error.

### error-number 

    method error-number(Audio::Sndfile:D:) returns Int

This returns non-zero if there was an error in the last read, write or open operation. The actual error message can be obtained with [error](#error) below.

### error 

    method error(Audio::Sndfile:D:) returns Str

This will return the string describing the last error if [error-number](#error-number) was non-zero or 'No Error' otherwise.

### sync

    method sync(Audio::Sndfile:D:) returns Int

If the file is opened for writing then any buffered data will be flushed to disk. If the file was opened for reading it does nothing.

### read-short

    multi method read-short(Audio::Sndfile:D: Int $frames) returns Array[int16]
    multi method read-short(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[int16], Int]

This returns an array of size `$frames` * $num-channels of 16 bit integers from the opened file. The returned array may be empty or shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array containing the raw CArray returned from the underlying library and the number of frames. This is for convenience (and efficiency ) where the data is going to be passed directly to another native libray function.

### write-short

    multi method write-short(Audio::Sndfile:D: @frames) returns Int
    multi method write-short(Audio::Sndfile:D: CArray[int16] $frames-in, Int $frames) returns Int

This writes the array @frames of 16 bit integers to the file. @frames must have a number of elements that is a multiple of the number of channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error will occur.

If the values are outside the range for an int16 then wrapping will occur.

The second multi is for the convenience of applications which may have obtained their data from some native function.

### read-int

    multi method read-int(Audio::Sndfile:D: Int $frames) returns Array[Int]
    multi method read-int(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[int32], Int]

This returns an array of size `$frames` * $num-channels of 32 bit integers from the opened file. The returned array may be empty or shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array containing the raw CArray returned from the underlying library and the number of frames. This is for convenience (and efficiency ) where the data is going to be passed directly to another native libray function.

### write-int

    multi method write-int(Audio::Sndfile:D: @frames) returns Int
    multi method write-int(Audio::Sndfile:D: CArray[int32] $frames-in, Int $frames) returns Int

This writes the array @frames of 32 bit integers to the file. @frames must have a number of elements that is a multiple of the number of channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error will occur.

If the values are outside the range for an int32 then wrapping will occur.

The second multi is for the convenience of applications which may have obtained their data from some native function.

### read-float

    multi method read-float(Audio::Sndfile:D: Int $frames) returns Array[num32]
    multi method read-float(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[num32], Int]

This returns an array of size `$frames` * $num-channels of 32 bit floating point numbers from the opened file. The returned array may be empty or shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array containing the raw CArray returned from the underlying library and the number of frames. This is for convenience (and efficiency ) where the data is going to be passed directly to another native libray function.

### write-float

    multi method write-float(Audio::Sndfile:D: @frames) returns Int
    multi method write-float(Audio::Sndfile:D: CArray[num32] $frames-in, Int $frames) returns Int

This writes the array @frames of 32 bit floating point numbers to the file. @frames must have a number of elements that is a multiple of the number of channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error will occur.

If the values are outside the range for a num32 then wrapping will occur.

The second multi is for the convenience of applications which may have obtained their data from some native function.

### read-double

    multi method read-double(Audio::Sndfile:D: Int $frames) returns Array[num64]
    multi method read-double(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[num64], Int]

This returns an array of size `$frames` * $num-channels of 64 bit floating point numbers from the opened file. The returned array may be empty or shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array containing the raw CArray returned from the underlying library and the number of frames. This is for convenience (and efficiency ) where the data is going to be passed directly to another native libray function.

### write-double

    multi method write-double(Audio::Sndfile:D: @frames) returns Int
    multi method write-double(Audio::Sndfile:D: CArray[num64] $frames-in, Int $frames) returns Int

This writes the array @frames of 64 bit floating point numbers to the file. @frames must have a number of elements that is a multiple of the number of channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error will occur.

If the values are outside the range for a num64 then wrapping will occur.

As of the time of the initial release, this may fail if the frame data was directly retrieved via [read-double](#read-double) due to an infelicity in the runtime, this should be fixed at some point but can be worked around by copying the values.

The second multi is for the convenience of applications which may have obtained their data from some native function.

### clone-info

    method clone-info(Audio::Sndfile:D: ) returns Audio::Sndfile::Info

This returns a new [Audio::Sndfile::Info](Audio::Sndfile::Info) based on the details of the current file suitable for being passed to [new](#new) for instance when copying or converting the file.

NAME
====

Audio::Sndfile::Info - describe an opened audio file

SYNOPSIS
========

        my $info = Audio::Sndfile::Info.new(channels => 2, samplerate => 44100, format => 0x00010002);
        say $info.type;

DESCRIPTION
===========

The objects of type [Audio::Sndfile::Info](Audio::Sndfile::Info) can be passed to the constructor of [Audio::Sndfile](Audio::Sndfile) when opening the file for writing and can be obtained from the `info` accessor of an [Audio::Sndfile](Audio::Sndfile) that was opened for reading. It is a representation of the `SF_INFO` struct used by `libsndfile` to pass this information around.

It is unlikely that changing the values of any of the attributes in the object will make sense after the object has been constructed.

METHODS
-------

Where indicated some of these attributes can be passed as named arguments to  [Audio::Sndfile](Audio::Sndfile) constructor when opening for writing.

### frames

This returns an Int indicating the number of the frames in a file, this only makes sense when the file is opened for reading, it is ignored when the file is opened for writing and it is not updated while new data is written to the file. The number of frames is the number of sample items / channels.

### channels

The number of channels in the data of this file. This is required when opening a file for writing.

### format

An Int that describes the format of the file. This is the bitwise or of `type`, `sub-type` and `endian`. It is required when opening a file for writing and providing a value that is not legal will result in an exception.

### samplerate

This is the sample rate of the frame data in frames / second. This is required when opening a file for writing. It is important to note though that if data is being read from one file and written to the other (i.e. copying or format converting) then setting this to any other value than that of the incoming file will not cause an automatic sample rate conversion and will simply have the effect of slowing down or speeding up the playback of the written data. If you want samplerate conversion you will either need to process the data yourself to add or remove the required frames (inferring the values in the up-sampling case,) or use some other library such as `libsamplerate`.

### sections

An Int that indicates the number of (format dependent) sections in the file. This is not required for opening a file for writing.

### seekable

This is a Boolean to indicate whether the input or output file is seekable, it will be true for most regular files and False for other special files, however as it is currently difficult to open other than regular files this can be mostly ignored.

### format-check

    method format-check() returns Bool

This returns a Bool to indicate whether the [format](#format) in the current object makes sense. Attempting to use a setting of [format](#format) where this is not true will cause an exception to be thrown.

### type

    method type() returns Format

This is a value of the enum [Audio::Sndfile::Info::Format](Audio::Sndfile::Info::Format) that indicates the major format of the file (e.g. WAV, FLAC ..). It is bitwise or-ed with `sub-type` and `endian` to provide [format](#format).

### sub-type

    method sub-type() returns Subformat

This is a value of the enum [Audio::Sndfile::Info::Subformat](Audio::Sndfile::Info::Subformat) that indicate the minor format or sample encoding of the data (e.g. PCM_16, FLOAT ... ). It is bitwise or-ed with `type` and `endian` to provide [format](#format).

### endian

    method endian() returns End

This is a value of the enum [Audio::Sndfile::Info::End](Audio::Sndfile::Info::End) which indicates the endian-ness of the samples in the data. It is bitwise or-ed with `type` and `sub-type` to make [format](#format).

### duration

    method duration() returns Duration

enum Audio::Sndfile::Info::Format
---------------------------------

This describes the major format of the file as described above in [type](#type). The possible values are described below, it should be borne in mind that only certain combinations of `type` and `sub-type` make sense, this is detailed in [http://www.mega-nerd.com/libsndfile/#Features](http://www.mega-nerd.com/libsndfile/#Features)

  * WAV

    Microsoft WAV format (little endian default).

  * AIFF

    Apple/SGI AIFF format (big endian).

  * AU

    Sun/NeXT AU format (big endian).

  * RAW

    RAW PCM data.

  * PAF

    Ensoniq PARIS file format.

  * SVX

    Amiga IFF / SVX8 / SV16 format.

  * NIST

    Sphere NIST format.

  * VOC

    VOC files.

  * IRCAM

    Berkeley/IRCAM/CARL

  * W64

    Sonic Foundry's 64 bit RIFF/WAV

  * MAT4

    Matlab (tm) V4.2 / GNU Octave 2.0

  * MAT5

    Matlab (tm) V5.0 / GNU Octave 2.1

  * PVF

    Portable Voice Format

  * XI

    Fasttracker 2 Extended Instrument

  * HTK

    HMM Tool Kit format

  * SDS

    Midi Sample Dump Standard

  * AVR

    Audio Visual Research

  * WAVEX

    MS WAVE with WAVEFORMATEX

  * SD2

    Sound Designer 2

  * FLAC

    FLAC lossless file format

  * CAF

    Core Audio File format

  * WVE

    Psion WVE format

  * OGG

    Xiph OGG container

  * MPC2K

    Akai MPC 2000 sampler

  * RF64

    RF64 WAV file

enum Audio::Sndfile::Info::Subformat
------------------------------------

These describe the minor format or sample encoding of the format. As suggested above only certain combnations of Format and Subformat actually make sense.

  * PCM_S8

    Signed 8 bit data

  * PCM_16

    Signed 16 bit data

  * PCM_24

    Signed 24 bit data

  * PCM_32

    Signed 32 bit data

  * PCM_U8

    Unsigned 8 bit data (WAV and RAW only)

  * FLOAT

    32 bit float data

  * DOUBLE

    64 bit float data

  * ULAW

    U-Law encoded.

  * ALAW

    A-Law encoded.

  * IMA_ADPCM

    IMA ADPCM.

  * MS_ADPCM

    Microsoft ADPCM.

  * GSM610

    GSM 6.10 encoding.

  * VOX_ADPCM

    OKI / Dialogix ADPCM

  * G721_32

    32kbs G721 ADPCM encoding.

  * G723_24

    24kbs G723 ADPCM encoding.

  * G723_40

    40kbs G723 ADPCM encoding.

  * DWVW_12

    12 bit Delta Width Variable Word encoding.

  * DWVW_16

    16 bit Delta Width Variable Word encoding.

  * DWVW_24

    24 bit Delta Width Variable Word encoding.

  * DWVW_N

    N bit Delta Width Variable Word encoding.

  * DPCM_8

    8 bit differential PCM (XI only)

  * DPCM_16

    16 bit differential PCM (XI only)

  * VORBIS

    Xiph Vorbis encoding.

Audio::Sndfile::Info::End
-------------------------

These describe the endian-ness of the file format. Typically a file opened for reading will use `File` if the format defines an endian-ness and this should also be used when opening a file for writing unless there is some particular reason not to.

  * File

Default file endian-ness

  * Little

Force little endian-ness

  * Big

Force big endian-ness.

  * Cpu

Force CPU endian-ness.
