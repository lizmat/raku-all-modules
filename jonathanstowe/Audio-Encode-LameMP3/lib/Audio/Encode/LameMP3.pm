use v6;

=begin pod

=head1 NAME

Audio::Encode::LameMP3 - encode PCM data to MP3 using libmp3lame

=head1 SYNOPSIS

=begin code

    use Audio::Encode::LameMP3;
    use Audio::Sndfile;

    my $test-file = 't/data/cw_glitch_noise15.wav';

    my $sndfile = Audio::Sndfile.new(filename => $test-file, :r);
    my $encoder = Audio::Encode::LameMP3.new(bitrate => 128, quality => 3, in-samplerate => $sndfile.samplerate);

    my $out-file = 'encoded.mp3'.IO.open(:w, :bin);

    loop {
        my @in-frames = $sndfile.read-short(4192);
        my $buf = $encoder.encode-short(@in-frames);
        $out-file.write($buf);
        last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();
    my  $buf = $encoder.encode-flush();
    $out-file.write($buf);
    $out-file.close;

=end code

See also the C<examples/> directory in the distribution.

=head1 DESCRIPTION

This module provides a simple binding to "libmp3lame" an MP3 encoding library.

With this you can encode PCM data to MP3 at any bitrate or quality
supported by the lame library.

The interface is somewhat simplified in comparison to that of lame
and some of the esoteric or rarely used features may not be supported.

Because marshalling large arrays and buffers between perl space and the
native world may be too slow for some use cases the interface provides
for passing and returning native CArrays (and their sizes) for the use
of other native bindings (e.g. L<Audio::Sndfile>, L<Audio::Libshout>) where 
speed may prove important, which , for me at least, is quite a common
use-case.  The C<p6lame_encode> example demonstrates this way of using
the interface.

=head2 METHODS

All of the encode methods below have multi variants that accept appropriately
shaped CArray arguments (along with the number of frames.)  With the C<:raw>
adverb they will return a C<RawEncode> sub-set which is defined as an Array
of two elements the first being a C<CArray[uint8]> containing the encoded
data and an C<Int> indicating how many items there are.  This is for ease of
interoperating with modules such as L<Audio::Sndfile> and L<Audio::Libshout>
and avoids the cost of marshalling to/from perl Arrays where it is not needed.

=head3 method new

    method new(*%attributes) returns Audio::Encode::LameMP3

The constructor of objects of this type, this can be passed any of the
encoder parameters or id3 tags described below.  It will set some internal
defaults.

=head3 method init

    method init() 

This initialises the encoder ready to start the encoding.  It may be called after
all the rquired parameters have been set, however it will be called for you when
the first encode method is called.  It is an error to attempt to set any encoding
parameters after C<init> has been called.

=head3 method init-bitstream

    method init-bitstream() 

This can be used to re-initialise the encoder's internal state in order that it
can be re-used for the encoding of a new source (e.g. a new file.)  It should only
be called after C<encode-flush> has been called and the result of doing otherwise
is undefined.  Typically this could be used when streaming multiple files in sequence
to the the same stream endpoint for example, calling C<encode-flush> and C<init-bitstream>
between each file.

This is not necessary on the first initialisation as it is called by C<init()>

=head3 method lame-version

    method lame-version() returns Version 

This returns a L<Version> object indicating the version of C<libmp3lame> that is
being used.  

=head3 method encode-short

Encode the block of PCM data expressed as signed 16 bit integers to
MP3 returning the data as unsigned 8 bit integers.  The input data
can be provided either as separate channels or in interleaved form.
The multi variants allow the data to provided as perl arrays or as
C<CArray[int16]> and the number of frames ( the number of frames is the
number left channel, right channel pairs.)

If the C<:raw> adverb is provided then the data will be returned as a
two element array containing a C<CArray[uint8]> and an C<Int> with the
number of elements in the array. Otherwise it will return a perl Array
with the data.

Tests seem to demonstrate that this is the fastest of the encoding
methods, which is convenient as 16 bit PCM is probably the most common
format for general use (being that which is used on CDs.)


    multi method encode-short(@left, @right) returns Buf 
    multi method encode-short(@frames) returns Buf 
    multi method encode-short(@left, @right, :$raw!) returns RawEncode 
    multi method encode-short(@frames, :$raw!) returns RawEncode 
    multi method encode-short(CArray[int16] $left, CArray[int16] $right, Int $frames) returns Buf 
    multi method encode-short(CArray[int16] $frames-in, Int $frames) returns Buf 
    multi method encode-short(CArray[int16] $left, CArray[int16] $right, Int $frames, :$raw!) returns RawEncode 
    multi method encode-short(CArray[int16] $frames-in, Int $frames, :$raw!) returns RawEncode 

=head3 method encode-int

Encode the block of PCM data expressed as 32 bit integers to MP3 returning
the data as unsigned 8 bit integers.  The input data can be provided
either as separate channels or in interleaved form.  The multi variants
allow the data to provided as perl arrays or as C<CArray[int32]> and
the number of frames ( the number of frames is the number left channel,
right channel pairs.)

If the C<:raw> adverb is provided then the data will be returned as a
two element array containing a C<CArray[uint8]> and an C<Int> with the
number of elements in the array. Otherwise it will return a perl Array
with the data.

C<libmp3lame> doesn't provide the interleaved data option for this data
type so it is emulated in perl code so it may be slower if used like that.

The C<libmp3lame> documentation suggests that the scaling of the integer
encoding may not be as good as for other data types, if you need to
use this data type you should test this and provide your own scaling
if necessary.

    multi method encode-int(@left, @right) returns Buf 
    multi method encode-int(@frames) returns Buf 
    multi method encode-int(@left, @right, :$raw!) returns RawEncode 
    multi method encode-int(@frames, :$raw!) returns RawEncode 
    multi method encode-int(CArray[int32] $left, CArray[int32] $right, Int $frames) returns Buf 
    multi method encode-int(CArray[int32] $frames-in, Int $frames) returns Buf 
    multi method encode-int(CArray[int32] $left, CArray[int32] $right, Int $frames, :$raw!) returns RawEncode 
    multi method encode-int(CArray[int32] $frames-in, Int $frames, :$raw!) returns RawEncode 

=head3 method encode-long

Encode the block of PCM data expressed as 64 bit integers to MP3 returning
the data as unsigned 8 bit integers.  The input data can be provided
either as separate channels or in interleaved form.  The multi variants
allow the data to provided as perl arrays or as C<CArray[int64]> and
the number of frames ( the number of frames is the number left channel,
right channel pairs.)

If the C<:raw> adverb is provided then the data will be returned as a
two element array containing a C<CArray[uint8]> and an C<Int> with the
number of elements in the array. Otherwise it will return a perl Array
with the data.

C<libmp3lame> doesn't provide the interleaved data option for this data
type so it is emulated in perl code so it may be slower if used like that.

    multi method encode-long(@left, @right) returns Buf 
    multi method encode-long(@frames) returns Buf 
    multi method encode-long(@left, @right, :$raw!) returns RawEncode 
    multi method encode-long(@frames, :$raw!) returns RawEncode 
    multi method encode-long(CArray[int64] $left, CArray[int64] $right, Int $frames) returns Buf 
    multi method encode-long(CArray[int64] $frames-in, Int $frames) returns Buf 
    multi method encode-long(CArray[int64] $left, CArray[int64] $right, Int $frames, :$raw!) returns RawEncode 
    multi method encode-long(CArray[int64] $frames-in, Int $frames, :$raw!) returns RawEncode 

=head3 method encode-float 

Encode the block of PCM data expressed as 32 bit floating point numbers
to MP3 returning the data as unsigned 8 bit integers.  The input data
can be provided either as separate channels or in interleaved form.
The multi variants allow the data to provided as perl arrays or as
C<CArray[num32]> and the number of frames ( the number of frames is the
number left channel, right channel pairs.)

If the C<:raw> adverb is provided then the data will be returned as a
two element array containing a C<CArray[uint8]> and an C<Int> with the
number of elements in the array. Otherwise it will return a perl Array
with the data.

    multi method encode-float(@left, @right) returns Buf 
    multi method encode-float(@frames) returns Buf 
    multi method encode-float(@left, @right, :$raw!) returns RawEncode 
    multi method encode-float(@frames, :$raw!) returns RawEncode 
    multi method encode-float(CArray[num32] $left, CArray[num32] $right, Int $frames) returns Buf 
    multi method encode-float(CArray[num32] $frames-in, Int $frames) returns Buf 
    multi method encode-float(CArray[num32] $left, CArray[num32] $right, Int $frames, :$raw!) returns RawEncode 
    multi method encode-float(CArray[num32] $frames-in, Int $frames, :$raw!) returns RawEncode 

=head3 method encode-double

Encode the block of PCM data expressed as 64 bit floating point numbers
to MP3 returning the data as unsigned 8 bit integers.  The input data
can be provided either as separate channels or in interleaved form.
The multi variants allow the data to provided as perl arrays or as
C<CArray[num64]> and the number of frames ( the number of frames is the
number left channel, right channel pairs.)

If the C<:raw> adverb is provided then the data will be returned as a
two element array containing a C<CArray[uint8]> and an C<Int> with the
number of elements in the array. Otherwise it will return a perl Array
with the data.

    multi method encode-double(@left, @right) returns Buf 
    multi method encode-double(@frames) returns Buf 
    multi method encode-double(@left, @right, :$raw!) returns RawEncode 
    multi method encode-double(@frames, :$raw!) returns RawEncode 
    multi method encode-double(CArray[num64] $left, CArray[num64] $right, Int $frames) returns Buf 
    multi method encode-double(CArray[num64] $frames-in, Int $frames) returns Buf 
    multi method encode-double(CArray[num64] $left, CArray[num64] $right, Int $frames, :$raw!) returns RawEncode 
    multi method encode-double(CArray[num64] $frames-in, Int $frames, :$raw!) returns RawEncode 

=head3 method encode-flush

This returns (flushes) the last encoded data and should always be called
after the last PCM data for a particular stream has been encoded. It
may return up to 8000 bytes of data.

If the C<:nogap> adverb is supplied then the padding at the end will
be adjusted such that a subsequent track (or file) will appear to
play seamlessly, typically this will be used with C<init-bitstream>
which should be called after this and before sending further PCM data
to create an (apparently) gapless stream.

If the C<:raw> adverb is provided then the data will be returned as a
two element array containing a C<CArray[uint8]> and an C<Int> with the
number of elements in the array. Otherwise it will return a perl Array
with the data.

    multi method encode-flush() returns Buf 
    multi method encode-flush(:$nogap!) returns Buf 
    multi method encode-flush(:$raw!) returns RawEncode 
    multi method encode-flush(:$nogap!, :$raw!) returns RawEncode 

=head2 CONFIGURATION ATTRIBUTES

All of those can be supplied to the constructor or can be set as attributes
on a constructed object before it is initialised.  Some are more useful
than others as the library provides sensible defaults.  

The lame library provides a wider range of settable parameters that are not
exposed as I either don't understand them or they don't seem to be useful.

If of course you need a particular parameter, please feel free to request
it to be added - most of the native stubs are there, just not exposed as
methods.

The first four are the most likely to be used in most code.

=head3 in-samplerate

This should reflect the samplerate of the input PCM data. The default
is 44100.  If this is not set correctly the speed of the playback of
the encoded data will be incorrect.

=head3 bitrate

This is the playback bitrate of the encoded data. It should be a value
understood by both lame and the target players,  values that are fairly
universally understood are 64, 128, 192 and 320.

=head3 quality

This is an integer value between 0 and 9 that indicates the quality 
(and hence the speed) of the encoding, where 0 is the best (and slowest)
and 9 is the least good and fastest.  The default is 5.  Most applications
will typically use a value between 3 and 7 but your ears and patience might
better than mine.

=head3 mode

This is a value of the C<enum> L<Audio::Encode::LameMP3::MPEG-Mode> with the
following items:

=item Stereo 

For lame this setting is probably un-necessary.  The stereo channels are
encoded separately and this may result in greater loss of stereo field
information than C<JointStereo>.

=item JointStereo 

This is the most common setting for most uses.  The stereo channel separation
is essentially encoded losslessly in lame.

=item DualChannel 

This is not implemented as a separate mode by lame, setting this will have no
effect.

=item Mono 

The input source is to be encoded as mono.  If interleaved data is presented
then it will be read as if it represents a single channel.  If separate
channels are presented only the left channel will be encoded,

=item NotSet

This is the default.  The library will infact encode as C<JointStereo> by default.

=head3 num-samples

If the number of samples that will be encoded is known in advance (for instance
where the PCM data is read from a file.) this can be set.  The default is 2^31
samples.  If it is set the encoder may be able to make certain small optimisations.

=head3 num-channels

This should be either 1 or 2. lame doesn't support a greater number of channels
(e.g. surround modes) Setting this is probably completely un-necessary.

=head3 scale

This is a scaling factor between 0 and 1 that will be applied to the input data
before encoding.  The default is 1.

=head3 scale-left

scaling between 0 and 1 for the left channel. The default is undefined as C<scale>
will be used.

=head3 scale-right

scaling between 0 and 1 for the right channel. The default is undefined as C<scale>
will be used.

=head3 out-samplerate

This is the target samplerate of the encoded output (i.e. the samplerate of the 
resulting PCM if the output were decoded.) The default is the same as the input
samplerate and it probably isn't necessary to change it unless some target software
or hardware requires a particular samplerate. If you want finer control over the
samplerate you may consider using another library such as 'libsamplerate'

=head2 ID3 Attributes

These will cause ID3 tags to be inserted into the output stream.  For some reason
there are no getters for these in 'lame' so they all return an undefined L<Str>.

Both ID3 v1 and v2 tags will be created.

These are quite limited, if you are saving to a file and want finer control
over the tags you might want to consider L<Audio::Taglib::Simple> which will let
you add more tags more flexibly.

These can be either applied to the constructor as parameters or as
attributes on an L<Audio::Encode::LameMP3> object before the encoder
is initialised.  Additionally the may be set as attributes after
C<encode-flush> has been called and before it is reinitialised.

=head3 title

The title tag.

=head3 artist

The artist.

=head3 album

The album.

=head3 year

The year (this is a string that should look like a year e.g. "2015" )

=head3 comment

A comment. The id3v2 tag is created with a language of "XXX" for some reason.

=end pod

class Audio::Encode::LameMP3:ver<v0.0.3>:auth<github:jonathanstowe> {
    use NativeCall;
    use AccessorFacade;
    use NativeHelpers::Array;

    # Output of ':raw' methods for notational convenience
    subset RawEncode of Array where  ($_.elems == 2 ) && ($_[0] ~~ CArray[uint8]) && ($_[1] ~~ Int);

    enum EncodeError ( Okay => 0, BuffTooSmall => -1, Malloc => -2, NotInit => -3, Psycho => -4 );

    class X::LameError is Exception {
        has Str $.message;
    }

    class X::EncodeError is X::LameError {
        has Str $.message;
        has EncodeError $.error;

        multi method message() {
            if not $!message.defined {
                $!message = do given $!error {
                    when BuffTooSmall {
                        "supplied buffer too small for encoded output";
                    }
                    when Malloc {
                        "unable to allocate enough memory to perform encoding";
                    }
                    when NotInit {
                        "global flags not initialised before encoding";
                    }
                    when Psycho {
                        "problem with psychoacoustic model";
                    }
                    default {
                        "unknown or not an error";
                    }
                }
            }
            $!message;
        }
    }

    enum VBR-Mode <Off MT RH ABR MTRH>;
    enum MPEG-Mode <Stereo JointStereo DualChannel Mono NotSet>;
    enum PaddingType <No All Adjust>;

    # Values returned by the encode functions

    class GlobalFlags is repr('CPointer') {

        sub lame_init() returns GlobalFlags is native('libmp3lame') { * }

        method new(GlobalFlags:U: *%params) {
            my $lgf = lame_init();

            # call this here so we can add tags from the params.
            $lgf.id3tag_init();

            for %params.kv -> $param, $value {
                if $lgf.can($param) {
                    $lgf."$param"() = $value;
                }
            }
            $lgf;
        }

        # If we want to add id3 tags in the stream we need to set this before we
        # start adding them so call it in the constructor
        sub id3tag_init(GlobalFlags) is native('libmp3lame') { * }
        
        method id3tag_init() {
            id3tag_init(self);
            # everyone wants v2 tags right?
            self.id3-tag-add-v2();
        }

        sub id3tag_add_v2(GlobalFlags) is native('libmp3lame') { * }

        method id3-tag-add-v2() {
            id3tag_add_v2(self);
        }

        # The functions to set id3 tags have no get equivalents
        # neither do they return anything to indicate they worked.

        # Just use accessor facade with no return
        sub empty-get(GlobalFlags $) { Str }
        sub manage(GlobalFlags $self, Str $value is copy ) {
            explicitly-manage($value);
            $value;
        }

        role ID3Tag { }

        multi sub trait_mod:<is>(Method $m, :$id3tag! ) {
            $m does ID3Tag;
        }

        sub id3tag_set_title(GlobalFlags, Str) is native('libmp3lame') { * }

        method title() returns Str is rw is accessor-facade(&empty-get, &id3tag_set_title, &manage) is id3tag { * }

        sub id3tag_set_artist(GlobalFlags, Str) is native('libmp3lame') { * }

        method artist() returns Str is rw is accessor-facade(&empty-get, &id3tag_set_artist, &manage) is id3tag { }

        sub id3tag_set_album(GlobalFlags, Str) is native('libmp3lame') { * }

        method album() returns Str is rw is accessor-facade(&empty-get, &id3tag_set_album, &manage) is id3tag { }

        sub id3tag_set_year(GlobalFlags, Str) is native('libmp3lame') { * }

        method year() returns Str is rw is accessor-facade(&empty-get, &id3tag_set_year, &manage) is id3tag { }

        sub id3tag_set_comment(GlobalFlags, Str) is native('libmp3lame') { * }

        method comment() returns Str is rw is accessor-facade(&empty-get, &id3tag_set_comment, &manage) is id3tag { }

        sub check(GlobalFlags $self, Int $rc, Str :$what = 'unknown method') {
            if $rc < 0 {
                X::LameError.new(message => "Error setting parameter").throw
            }
            $rc;
        }

        # utilities

        sub get-buffer-size(Int $no-frames ) returns Int {
            my $num = ((1.25 * $no-frames) + 7200).Int;
            $num;
        }

        sub get-out-buffer(Int $size) returns CArray[uint8] {
            my $buff =  CArray[uint8].new;
            $buff[$size] = 0;
            $buff;
        }

        multi method encode(@left, @right, &encode-func, Mu $type ) returns Buf {
            my ($buffer, $bytes-out) = self.encode(@left, @right, &encode-func, $type, :raw ).list;
            copy-carray-to-buf($buffer, $bytes-out);
        }

        multi method encode(CArray $left-in, CArray $right-in, Int $frames, &encode-func ) returns Buf {
            my ($buffer, $bytes-out) = self.encode($left-in, $right-in, $frames, &encode-func, :raw ).list;
            copy-carray-to-buf($buffer, $bytes-out);
        }

        multi method encode(@left, @right, &encode-func, Mu $type, :$raw!) returns RawEncode {
            if (@left.elems == @right.elems ) {

                my $left-in   = copy-to-carray(@left, $type);
                my $right-in  = copy-to-carray(@right, $type);
                my $frames    = @left.elems;
                self.encode($left-in, $right-in, $frames, &encode-func, :raw);
            }
            else {
                X::EncodeError.new(message => "not equal length frames in");
            }
        }

        multi method encode(CArray $left-in, CArray $right-in, Int $frames, &encode-func, :$raw!)  returns RawEncode {
            my $buff-size = get-buffer-size($frames);
            my $buffer    = get-out-buffer($buff-size);
            my $bytes-out = &encode-func(self, $left-in, $right-in,  $frames, $buffer, $buff-size);
            if $bytes-out < 0 {
                X::EncodeError.new(error => EncodeError($bytes-out)).throw;
            }
            [$buffer, $bytes-out];
        }

        multi method encode(@frames, &encode-func, Mu $type ) returns Buf {
            my ( $buffer, $bytes-out ) = self.encode(@frames, &encode-func, $type, :raw ).list;
            copy-carray-to-buf($buffer, $bytes-out);
        }

        multi method encode(CArray $frames-in, Int $frames, &encode-func ) returns Buf {
            my ( $buffer, $bytes-out ) = self.encode($frames-in, $frames, &encode-func, :raw ).list;
            copy-carray-to-buf($buffer, $bytes-out);
        }

        multi method encode(@frames, &encode-func, Mu $type, :$raw! ) returns RawEncode {
            if (@frames.elems % 2 ) == 0  {

                my $frames-in   = copy-to-carray(@frames, $type);
                my $frames    = (@frames.elems / 2).Int;
                self.encode($frames-in, $frames, &encode-func, :raw);
            }
            else {
                X::EncodeError.new(message => "not equal length frames in");
            }
        }

        multi method encode(CArray $frames-in, Int $frames, &encode-func, :$raw!) returns RawEncode {
            my $buff-size = get-buffer-size($frames);
            my $buffer    = get-out-buffer($buff-size);

            my $bytes-out = &encode-func(self, $frames-in, $frames, $buffer, $buff-size);

            if $bytes-out < 0 {
                X::EncodeError.new(error => EncodeError($bytes-out)).throw;
            }
            [ $buffer, $bytes-out ];
        }

        # encode functions all return the number of bytes in the encoded output or a value less than 0
        # from the enum EncodeError above

        # Non-interleaved inputs are left, right. num_samples is actually number of frames.
        sub lame_encode_buffer(GlobalFlags, CArray[int16], CArray[int16], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-short(@left, @right) returns Buf {
            self.encode(@left, @right, &lame_encode_buffer, int16);
        }

        multi method encode-short(@left, @right, :$raw!) returns RawEncode {
            self.encode(@left, @right, &lame_encode_buffer, int16, :raw);
        }

        multi method encode-short(CArray[int16] $left, CArray[int16] $right, Int $frames) returns Buf {
            self.encode($left, $right, $frames, &lame_encode_buffer);
        }

        multi method encode-short(CArray[int16] $left, CArray[int16] $right, Int $frames, :$raw!) returns RawEncode {
            self.encode($left, $right, $frames, &lame_encode_buffer, :raw);
        }

        sub lame_encode_buffer_interleaved(GlobalFlags, CArray[int16], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-short(@frames) returns Buf {
            self.encode(@frames, &lame_encode_buffer_interleaved, int16);
        }

        multi method encode-short(@frames, :$raw!) returns RawEncode {
            self.encode(@frames, &lame_encode_buffer_interleaved, int16, :raw);
        }

        multi method encode-short(CArray[int16] $frames-in, Int $frames) returns Buf {
            self.encode($frames-in, $frames, &lame_encode_buffer_interleaved);
        }

        multi method encode-short(CArray[int16] $frames-in, Int $frames, :$raw!) returns RawEncode {
            self.encode($frames-in, $frames, &lame_encode_buffer_interleaved, :raw);
        }

        # not sure what this one is about. The include file comment suggests it is ints but the signature suggests otherwise
        sub lame_encode_buffer_float(GlobalFlags, CArray[num32], CArray[num32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        # seemed to be scaled to floats as we know them
        sub lame_encode_buffer_ieee_float(GlobalFlags, CArray[num32], CArray[num32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-float(@left, @right) returns Buf {
            self.encode(@left, @right, &lame_encode_buffer_ieee_float, num32);
        }
        multi method encode-float(@left, @right, :$raw!) returns RawEncode {
            self.encode(@left, @right, &lame_encode_buffer_ieee_float, num32, :raw);
        }
        multi method encode-float(CArray[num32] $left, CArray[num32] $right, Int $frames) returns Buf {
            self.encode($left, $right, $frames, &lame_encode_buffer_ieee_float);
        }
        multi method encode-float(CArray[num32] $left, CArray[num32] $right, Int $frames, :$raw!) returns RawEncode {
            self.encode($left, $right, $frames, &lame_encode_buffer_ieee_float, :raw);
        }

        sub lame_encode_buffer_interleaved_ieee_float(GlobalFlags, CArray[num32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-float(@frames ) returns Buf {
            self.encode(@frames, &lame_encode_buffer_interleaved_ieee_float, num32);
        }
        multi method encode-float(@frames, :$raw! ) returns RawEncode {
            self.encode(@frames, &lame_encode_buffer_interleaved_ieee_float, num32, :raw);
        }
        multi method encode-float(CArray[num32] $frames-in, Int $frames ) returns Buf {
            self.encode($frames-in, $frames, &lame_encode_buffer_interleaved_ieee_float);
        }
        multi method encode-float(CArray[num32] $frames-in, Int $frames, :$raw! ) returns RawEncode {
            self.encode($frames-in, $frames, &lame_encode_buffer_interleaved_ieee_float, :raw);
        }

        sub lame_encode_buffer_ieee_double(GlobalFlags, CArray[num64], CArray[num64], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-double(@left, @right) returns Buf {
            self.encode(@left, @right, &lame_encode_buffer_ieee_float, num64);
        }
        multi method encode-double(@left, @right, :$raw!) returns RawEncode {
            self.encode(@left, @right, &lame_encode_buffer_ieee_float, num64, :raw);
        }
        multi method encode-double(CArray[num64] $left, CArray[num64] $right, Int $frames) returns Buf {
            self.encode($left, $right, $frames, &lame_encode_buffer_ieee_float);
        }
        multi method encode-double(CArray[num64] $left, CArray[num64] $right, Int $frames, :$raw!) returns RawEncode {
            self.encode($left, $right, $frames, &lame_encode_buffer_ieee_float, :raw);
        }

        sub lame_encode_buffer_interleaved_ieee_double(GlobalFlags, CArray[num64], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-double(@frames ) returns Buf {
            self.encode(@frames, &lame_encode_buffer_interleaved_ieee_double, num64);
        }
        multi method encode-double(@frames, :$raw! ) returns RawEncode {
            self.encode(@frames, &lame_encode_buffer_interleaved_ieee_double, num64, :raw);
        }
        multi method encode-double(CArray[num64] $frames-in, Int $frames ) returns Buf {
            self.encode($frames-in, $frames, &lame_encode_buffer_interleaved_ieee_double);
        }
        multi method encode-double(CArray[num64] $frames-in, Int $frames, :$raw! ) returns RawEncode {
            self.encode($frames-in, $frames, &lame_encode_buffer_interleaved_ieee_double, :raw);
        }

        # ignoring the long variant as it appears to be a mistake
        # neither have an interleaved variant
        sub lame_encode_buffer_long2(GlobalFlags, CArray[int64], CArray[int64], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-long(@left, @right) returns Buf {
            self.encode(@left, @right, &lame_encode_buffer_long2, int64);
        }

        multi method encode-long(@left, @right, :$raw!) returns RawEncode {
            self.encode(@left, @right, &lame_encode_buffer_long2, int64, :raw);
        }
        multi method encode-long(CArray[int64] $left, CArray[int64] $right, Int $frames) returns Buf {
            self.encode($left, $right, $frames, &lame_encode_buffer_long2);
        }

        multi method encode-long(CArray[int64] $left, CArray[int64] $right, Int $frames, :$raw!) returns RawEncode {
            self.encode($left, $right, $frames, &lame_encode_buffer_long2, :raw);
        }

        # the include suggests that the scaling may be wonky on this.
        sub lame_encode_buffer_int(GlobalFlags, CArray[int32], CArray[int32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-int(@left, @right) returns Buf {
            self.encode(@left, @right, &lame_encode_buffer_int, int32);
        }
        multi method encode-int(@left, @right, :$raw!) returns RawEncode {
            self.encode(@left, @right, &lame_encode_buffer_int, int32, :raw);
        }

        multi method encode-int(CArray[int32] $left, CArray[int32] $right, Int $frames) returns Buf {
            self.encode($left, $right, $frames, &lame_encode_buffer_int);
        }
        multi method encode-int(CArray[int32] $left, CArray[int32] $right, Int $frames, :$raw!) returns RawEncode {
            self.encode($left, $right, $frames, &lame_encode_buffer_int, :raw);
        }

        # The nogap variant means the stream can be reused or something return number of bytes (and I guess <0 is an error
        sub lame_encode_flush(GlobalFlags, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }
        # nogap allows you to continue using the same encoder - useful for streaming
        sub lame_encode_flush_nogap(GlobalFlags, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        # allocate an overly long buffer to take the last bit
        multi method encode-flush(:$nogap!) returns Buf {
            my ( $buffer, $bytes-out) = self.encode-flush(:nogap, :raw).list;
            copy-carray-to-buf($buffer, $bytes-out);
        }
        multi method encode-flush() returns Buf {
            my ( $buffer, $bytes-out) = self.encode-flush(:raw).list;
            copy-carray-to-buf($buffer, $bytes-out);
        }
        multi method encode-flush(:$nogap! , :$raw!) returns RawEncode {
            my $buffer = get-out-buffer(8192);
            my $bytes-out = lame_encode_flush_nogap(self, $buffer, 8192);

            if $bytes-out < 0 {
                X::EncodeError.new(error => EncodeError($bytes-out)).throw;
            }
            [$buffer, $bytes-out];
        }
        multi method encode-flush(:$raw!) returns RawEncode {
            my $buffer = get-out-buffer(8192);
            my $bytes-out = lame_encode_flush(self, $buffer, 8192);

            if $bytes-out < 0 {
                X::EncodeError.new(error => EncodeError($bytes-out)).throw;
            }
            [$buffer, $bytes-out];
        }


        sub lame_set_in_samplerate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_in_samplerate(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method in-samplerate() returns Int is rw
            is accessor-facade(&lame_get_in_samplerate, &lame_set_in_samplerate, Code, &check) { }

        sub lame_set_num_channels(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_num_channels(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method num-channels() returns Int
            is accessor-facade(&lame_get_num_channels, &lame_set_num_channels, Code, &check) { }

        sub lame_set_brate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_brate(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method bitrate() returns Int
            is accessor-facade(&lame_get_brate, &lame_set_brate, Code, &check) { }

        sub lame_set_quality(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quality(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method quality() returns Int
            is accessor-facade(&lame_get_quality, &lame_set_quality, Code, &check) { }


        sub lame_set_mode(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_mode(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method mode() returns MPEG-Mode
            is accessor-facade(&lame_get_mode, &lame_set_mode, Code, &check ) { }


        # below less commonly used

        sub lame_set_num_samples(GlobalFlags, uint64) returns int32 is native("libmp3lame") { * }
        sub lame_get_num_samples(GlobalFlags) returns uint64 is native("libmp3lame") { * }

        method num-samples() returns Int is rw
            is accessor-facade(&lame_get_num_samples, &lame_set_num_samples, Code, &check ) { }


        sub lame_set_scale(GlobalFlags, num32) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale(GlobalFlags) returns num32 is native("libmp3lame") { * }

        method scale() returns Num is rw
            is accessor-facade(&lame_get_scale, &lame_set_scale, Code, &check ) { }

        sub lame_set_scale_left(GlobalFlags, num32) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale_left(GlobalFlags) returns num32 is native("libmp3lame") { * }

        method scale-left() returns Num is rw
            is accessor-facade(&lame_get_scale_left, &lame_set_scale_left, Code, &check ) { }

        sub lame_set_scale_right(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale_right(GlobalFlags) returns Num is native("libmp3lame") { * }

        method scale-right() returns Num is rw
            is accessor-facade(&lame_get_scale_right, &lame_set_scale_right, Code, &check ) { }

        sub lame_set_out_samplerate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_out_samplerate(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method out-samplerate() returns Int is rw
            is accessor-facade(&lame_get_out_samplerate, &lame_set_out_samplerate, Code, &check ) { }


        sub lame_set_analysis(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_analysis(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method set-analysis() returns Bool is rw
            is accessor-facade(&lame_get_analysis, &lame_set_analysis, Code, &check ) { }


        sub lame_set_bWriteVbrTag(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_bWriteVbrTag(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method write-vbr-tag() returns Bool is rw
            is accessor-facade(&lame_get_bWriteVbrTag, &lame_set_bWriteVbrTag, Code, &check ) { }

        sub lame_set_decode_only(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_decode_only(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method decode-only() returns Bool is rw
            is accessor-facade(&lame_get_decode_only, &lame_set_decode_only, Code, &check ) { }


        sub lame_set_nogap_total(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_nogap_total(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method nogap-total() returns Int is rw
            is accessor-facade(&lame_get_nogap_total, &lame_set_nogap_total, Code, &check ) { }

        sub lame_set_nogap_currentindex(GlobalFlags , int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_nogap_currentindex(GlobalFlags) returns int32 is native("libmp3lame") { * }


        sub lame_set_compression_ratio(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_compression_ratio(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_preset( GlobalFlags, int32 ) returns int32 is native("libmp3lame") { * }
        sub lame_set_asm_optimizations( GlobalFlags, int32, int32 ) returns int32 is native("libmp3lame") { * }
        sub lame_set_copyright(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_copyright(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_original(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_original(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_error_protection(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_error_protection(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_extension(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_extension(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_strict_ISO(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_strict_ISO(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_disable_reservoir(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_disable_reservoir(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_quant_comp(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quant_comp(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_quant_comp_short(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quant_comp_short(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_exp_nspsytune(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_exp_nspsytune(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_msfix(GlobalFlags, num64)  is native("libmp3lame") { * }
        sub lame_get_msfix(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_VBR(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_q(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_q(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_quality(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_quality(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_VBR_mean_bitrate_kbps(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_mean_bitrate_kbps(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_min_bitrate_kbps(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_min_bitrate_kbps(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_max_bitrate_kbps(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_max_bitrate_kbps(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_hard_min(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_hard_min(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_lowpassfreq(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_lowpassfreq(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_lowpasswidth(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_lowpasswidth(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_highpassfreq(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_highpassfreq(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_highpasswidth(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_highpasswidth(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHonly(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHonly(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHshort(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHshort(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_noATH(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_noATH(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHtype(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHtype(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHlower(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHlower(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_athaa_type( GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_athaa_type( GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_athaa_sensitivity( GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_athaa_sensitivity( GlobalFlags ) returns Num is native("libmp3lame") { * }
        sub lame_set_useTemporal(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_useTemporal(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_interChRatio(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_interChRatio(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_no_short_blocks(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_no_short_blocks(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_force_short_blocks(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_force_short_blocks(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_emphasis(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_emphasis(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_version(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_encoder_delay(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_encoder_padding(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_framesize(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_mf_samples_to_encode( GlobalFlags  ) returns int32 is native("libmp3lame") { * }
        sub lame_get_size_mp3buffer( GlobalFlags  ) returns int32 is native("libmp3lame") { * }
        sub lame_get_frameNum(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_totalframes(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_RadioGain(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_AudiophileGain(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_PeakSample(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_get_noclipGainChange(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_noclipScale(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_get_id3v1_tag(GlobalFlags, CArray[uint8], int64) returns int64 is native("libmp3lame") { * }
        sub lame_get_id3v2_tag(GlobalFlags,CArray[uint8] , int64) returns int64 is native("libmp3lame") { * }
        sub lame_set_write_id3tag_automatic(GlobalFlags , int32)  is native("libmp3lame") { * }
        sub lame_get_write_id3tag_automatic(GlobalFlags) returns int32 is native("libmp3lame") { * }

        # Not the same interface
        sub lame_get_bitrate(int32, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_samplerate(int32, int32 ) returns int32 is native("libmp3lame") { * }

        # Not sure if these will work
        sub lame_set_errorf(GlobalFlags, &cb ( Str $fmt, *@args) ) returns int32 is native("libmp3lame") { * }
        sub lame_set_debugf(GlobalFlags, &cb ( Str $fmt, *@args)) returns int32 is native("libmp3lame") { * }
        sub lame_set_msgf  (GlobalFlags, &cb ( Str $fmt, *@args)) returns int32 is native("libmp3lame") { * }


        sub lame_init_params(GlobalFlags) returns int32 is native('libmp3lame') { * }

        method init() {
            my $rc = lame_init_params(self);

            if $rc != 0 {
                X::LameError.new(message => "Error initialising parameters").throw;
            }
        }

        # This is not necessary but using flush_nogap and this it is possible to reuse
        # the same encoder which may be useful for streaming
        sub lame_init_bitstream(GlobalFlags) returns int32 is native('libmp3lame') { * }

        method init-bitstream() {
            my $rc = lame_init_bitstream(self);

            if $rc != 0 {
                X::LameError.new(message => "Error (re)initialising bitstream").throw;
            }
        }

        # The API docs and the include differ in the necessity of calling this.
        # As we'll only be "streaming" I'll hedge.
        
        sub lame_mp3_tags_fid(GlobalFlags, Pointer) is native('libmp3lame') { * }

        method mp3-tags() {
            lame_mp3_tags_fid(self, Pointer);
        }


        sub lame_close(GlobalFlags) is native('libmp3lame') { * }

        method DESTROY() {
            lame_close(self);
        }
    }

    has GlobalFlags $!gfp handles <
                                    in-samplerate
                                    num-channels
                                    bitrate
                                    quality
                                    mode
                                    num-samples
                                    scale
                                    scale-left
                                    scale-right
                                    out-samplerate
                                    set-analysis
                                    write-vbr-tag
                                    decode-only
                                    nogap-total
                                    title
                                    artist
                                    album
                                    year
                                    comment
                                  >;

    has Bool $!initialised = False;

    method init() {
        if not $!initialised {
            $!gfp.init;
            $!initialised = True;
        }
    }


    # for some reason there aren't interleaved versions of all the
    # different encode variants
    multi sub uninterleave(@frames) {
        my ( $left, $right);
        ($++ %% 2 ?? $left !! $right).push: $_ for @frames;
        return $left, $right;
    }

    multi sub uninterleave(CArray $c, $frames) {
	    my $left = $c.WHAT.new;
	    my $right = $c.WHAT.new;

	    my $left-index = 0;
	    my $right-index = 0;

	    for ^(2 * $frames) -> $i {
		    if $i % 2 {
			    $right[$right-index++] = $c[$i];
		    }
		    else {
			    $left[$left-index++] = $c[$i];
		    }
	    }
	    return $left, $right;
    }

    multi method encode-short(@left, @right) returns Buf {
        self.init();
        $!gfp.encode-short(@left, @right);
    }

    multi method encode-short(@frames) returns Buf {
        self.init();
        $!gfp.encode-short(@frames);
    }
    multi method encode-short(@left, @right, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-short(@left, @right, :raw);
    }

    multi method encode-short(@frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-short(@frames, :raw);
    }

    multi method encode-short(CArray[int16] $left, CArray[int16] $right, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-short($left, $right, $frames);
    }

    multi method encode-short(CArray[int16] $frames-in, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-short($frames-in, $frames);
    }
    multi method encode-short(CArray[int16] $left, CArray[int16] $right, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-short($left, $right, $frames, :raw);
    }

    multi method encode-short(CArray[int16] $frames-in, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-short($frames-in, $frames, :raw);
    }

    multi method encode-int(@left, @right) returns Buf {
        self.init();
        $!gfp.encode-int(@left, @right);
    }

    multi method encode-int(@frames) returns Buf {
        self.init();
        my ( $left, $right ) = uninterleave(@frames);
        $!gfp.encode-int($left, $right);
    }

    multi method encode-int(@left, @right, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-int(@left, @right, :raw);
    }

    multi method encode-int(@frames, :$raw!) returns RawEncode {
        self.init();
        my ( $left, $right ) = uninterleave(@frames);
        $!gfp.encode-int($left, $right, :raw);
    }

    multi method encode-int(CArray[int32] $left, CArray[int32] $right, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-int($left, $right, $frames);
    }

    multi method encode-int(CArray[int32] $frames-in, Int $frames) returns Buf {
        self.init();
        my ( $left, $right ) = uninterleave($frames-in, $frames);
        $!gfp.encode-int($left, $right, $frames);
    }

    multi method encode-int(CArray[int32] $left, CArray[int32] $right, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-int($left, $right, $frames, :raw);
    }

    multi method encode-int(CArray[int32] $frames-in, Int $frames, :$raw!) returns RawEncode {
        self.init();
        my ( $left, $right ) = uninterleave($frames-in, $frames);
        $!gfp.encode-int($left, $right, $frames, :raw);
    }

    multi method encode-long(@left, @right) returns Buf {
        self.init();
        $!gfp.encode-long(@left, @right);
    }

    multi method encode-long(@frames) returns Buf {
        self.init();
        my ( $left, $right ) = uninterleave(@frames);
        $!gfp.encode-long($left, $right);
    }

    multi method encode-long(@left, @right, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-long(@left, @right, :raw);
    }

    multi method encode-long(@frames, :$raw!) returns RawEncode {
        self.init();
        my ( $left, $right ) = uninterleave(@frames);
        $!gfp.encode-long($left, $right, :raw);
    }

    multi method encode-long(CArray[int64] $left, CArray[int64] $right, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-long($left, $right, $frames);
    }

    multi method encode-long(CArray[int64] $frames-in, Int $frames) returns Buf {
        self.init();
        my ( $left, $right ) = uninterleave($frames-in, $frames);
        $!gfp.encode-long($left, $right, $frames);
    }

    multi method encode-long(CArray[int64] $left, CArray[int64] $right, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-long($left, $right, $frames, :raw);
    }

    multi method encode-long(CArray[int64] $frames-in, Int $frames, :$raw!) returns RawEncode {
        self.init();
        my ( $left, $right ) = uninterleave($frames-in, $frames);
        $!gfp.encode-long($left, $right, $frames, :raw);
    }

    multi method encode-float(@left, @right) returns Buf {
        self.init();
        $!gfp.encode-float(@left, @right);
    }

    multi method encode-float(@frames) returns Buf {
        self.init();
        $!gfp.encode-float(@frames);
    }

    multi method encode-float(@left, @right, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-float(@left, @right, :raw);
    }

    multi method encode-float(@frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-float(@frames, :raw);
    }

    multi method encode-float(CArray[num32] $left, CArray[num32] $right, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-float($left, $right, $frames);
    }

    multi method encode-float(CArray[num32] $frames-in, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-float($frames-in, $frames);
    }

    multi method encode-float(CArray[num32] $left, CArray[num32] $right, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-float($left, $right, $frames, :raw);
    }

    multi method encode-float(CArray[num32] $frames-in, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-float($frames-in, $frames, :raw);
    }

    multi method encode-double(@left, @right) returns Buf {
        self.init();
        $!gfp.encode-double(@left, @right);
    }

    multi method encode-double(@frames) returns Buf {
        self.init();
        $!gfp.encode-double(@frames);
    }

    multi method encode-double(@left, @right, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-double(@left, @right, :raw);
    }

    multi method encode-double(@frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-double(@frames, :raw);
    }

    multi method encode-double(CArray[num64] $left, CArray[num64] $right, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-double($left, $right, $frames);
    }

    multi method encode-double(CArray[num64] $frames-in, Int $frames) returns Buf {
        self.init();
        $!gfp.encode-double($frames-in, $frames);
    }

    multi method encode-double(CArray[num64] $left, CArray[num64] $right, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-double($left, $right, $frames, :raw);
    }

    multi method encode-double(CArray[num64] $frames-in, Int $frames, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-double($frames-in, $frames, :raw);
    }

    multi method encode-flush() returns Buf {
        self.init();
        $!gfp.encode-flush();
    }
    multi method encode-flush(:$nogap!) returns Buf {
        self.init();
        $!gfp.encode-flush(:nogap);
    }
    multi method encode-flush(:$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-flush(:raw);
    }
    multi method encode-flush(:$nogap!, :$raw!) returns RawEncode {
        self.init();
        $!gfp.encode-flush(:nogap, :raw);
    }

    method init-bitstream() {
        if $!initialised {
            $!gfp.init-bitstream();
        }
    }

    sub get_lame_version() returns Str is native('libmp3lame') { * }

    method lame-version() returns Version {
        my $v = get_lame_version();
        Version.new($v);
    }

    submethod BUILD(*%params) {
        $!gfp = GlobalFlags.new(|%params);
        # No file descriptor so this must be off;
        $!gfp.write-vbr-tag = False;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
