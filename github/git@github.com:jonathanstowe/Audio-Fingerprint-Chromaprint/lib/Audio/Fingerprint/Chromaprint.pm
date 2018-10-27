
use v6.c;
use NativeCall;
use NativeHelpers::Array;

=begin pod

=head1 NAME

Audio::Fingerprint::Chromaprint  - Get audio fingerprint using the chromaprint / AcoustID library

=head1 SYNOPSIS

=begin code

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

=end code

=head1 DESCRIPTION

This provides a mechanism for obtaining a fingerprint of some audio data
using the L<Chromaprint library|https://acoustid.org/chromaprint>, you
can use this to identify recorded audio or determine whether two audio
files are the same for instance.

You need several seconds worth of data in order to be able to get a
usable fingerprint, and for comparison of two files you will need to
ensure that you have the same number of samples, ideally you should
fingerprint the entire audio file, but this may be slow if you have
a large file.

The library only can handle integer PCM audio data, if you need to
deal with encoded data such as MP3 or Ogg/Vorbis you will need to
use another library to decode it to raw samples.

Depending on how the Chromaprint library was built, it may or may not
be safe to have multiple instances created at the same time, so it
is probably safest to take care you only have a single instance in
your application.

=head1 METHODS

=head2 method new

    method new(Int :$silence-threshold, Algorithm :$algorithm = Test2) returns Audio::Fingerprint::Chromaprint

This is the contructor for the class. If the chromaprint library 
was built with the faster C<fftw> library rather than ffmpeq
then the initialisation of the library is not thread-safe, so
it may be best to avoid having more than one instance at a time
in your application.

If the named parameter C<silence-threshold> is supplied then it should be
in the range of 0 - 32768 and will be used to modify the way in which the
analysis is done. It's probably best not to use this if the fingerprints
are to be shared with other systems, and if it is used it should be the
same for every calculation if the fingerprint is to be compared.

C<algorithm> is a value of the C<enum>
C<Audio::Fingerprint::Chromaprint::Algorithm>, the default is C<Test2>
(the values are C<Test1> to C<Test4>,) they aren't very well documented
so I would suggest sticking to the default. Obviously for
comparison purposes the algorithm used to generate the fingerprints
should be the same.

=head2 method version

    method version() returns Str

This returns a Str representing the version of the library being used.

=head2 method start

    method start(Int $samplerate, Int $channels) returns Bool

This prepares the chromaprint library to begin receiving the
samples for an audio file. This must be called before C<feed>.
The C<$samplerate> and C<$channels> should be an accurate
reflection of the data that is going to be fed.

=head2 method feed

    multi method feed(CArray $data, Int $frames) returns Bool
    multi method feed(@frames) returns Bool 

This adds the audio data that is to be analysed, the data
should be interleaved 16 bit signed integers. You will need
several seconds worth of data (which can be fed in pieces,)
to be able to get a usable fingerprint, so, depending on 
the samplerate of the audio data, you may need to feed at
minimum somewhere in the region of 100,000 frames.

The CArray candidate is more efficient as no conversion
needs to be done to the data before passing to the
underlying library function - C<$frames> should be the
number of items in C<$data> divided by the number of
channels, if you are getting the data with Audio::Sndfile
for example then these values will be those returned
by C<read-short> with the C<:raw> adverb.

If you provide C<@frames> as an array, it should contain
a number of indivual samples that is divisible by the
number of channels in the data, this value will be used
to calculate C<$frames>.

If C<start> hasn't been called (or if C<finish> has
already been called without a subsequent C<start> then
an exception will be thrown.

=head2 method finish

    method finish() returns Bool

This indicates to the library that the user has done feeding
data and that the remaining buffered data can be used to
calculate the fingerprint, if there is insufficient data
to calculate the fingerprint then the C<libchromaprint> may
rudely print a warning to C<STDERR>.

After C<finish> has been called then C<start> must be called
to allow the feeding of further data as the state of the
engine will be reset.

=head2 method fingerprint

    method fingerprint() returns Str

This returns the calculated fingerprint as a string, if there
was unsufficient data provided then the fingerprint may only
comprise 4 or 5 characters, rather than 23 or so that it 
should be.

=end pod

class Audio::Fingerprint::Chromaprint {

    constant LIB = [ 'chromaprint', v0 ];

    enum Algorithm ( Test1 => 0, Test2 => 1, Test3 => 2, Test4 => 3);


    sub chromaprint_get_version() returns Str is native(LIB) { * }

    method version() returns Str {
        chromaprint_get_version();
    }

    class Context is repr('CPointer') {

        sub chromaprint_new(int32 $algorithm) returns Context is native(LIB)  { * }

        method new(Context:U: Algorithm :$algorithm = Test2) returns Context {
            chromaprint_new($algorithm.Int);
        }

        sub chromaprint_free(Context $ctx) is native(LIB) { * }

        method free(Context:D:) {
            chromaprint_free(self);
        }


        sub chromaprint_set_option(Context  $ctx, Str $name, int32 $value ) is native(LIB) returns int32 { * }

        method silence-threshold(Context:D: Int $threshold) returns Bool {
            my $rc = chromaprint_set_option(self, 'silence_threshold', $threshold);
            Bool($rc);
        }

        sub chromaprint_start(Context $ctx, int32  $sample_rate, int32 $num_channels ) is native(LIB) returns int32 { * }

        method start(Context:D: Int $sample-rate, Int $channels) returns Bool {
            my $rc = chromaprint_start(self, $sample-rate, $channels);
            Bool($rc);
        }

        sub chromaprint_feed(Context $ctx, CArray[int16] $data, int32 $size ) is native(LIB) returns int32 { * }

        method feed(Context:D: CArray $data, Int $frames) returns Bool {
            my $rc = chromaprint_feed(self, $data, $frames);
            Bool($rc);
        }

        sub chromaprint_finish(Context $ctx ) is native(LIB) returns int32 { * }

        method finish(Context:D:) returns Bool {
            my $rc = chromaprint_finish(self);
            Bool($rc);
        }

        sub chromaprint_get_fingerprint(Context $ctx, Pointer[Str]  $fingerprint is rw ) is native(LIB) returns int32  { * }

        method fingerprint(Context:D:) returns Str {
            my $p = Pointer[Str].new;
            my $rc = chromaprint_get_fingerprint(self, $p);
            my $ret = $p.deref.encode.decode;
            self!dealloc($p);
            $ret;
        }

#-From /usr/include/chromaprint.h:188
#/**
# * Return the calculated fingerprint as an array of 32-bit integers.
# *
# * The caller is responsible for freeing the returned pointer using
# * chromaprint_dealloc().
# *
# * Parameters:
# *  - ctx: Chromaprint context pointer
# *  - fingerprint: pointer to a pointer, where a pointer to the allocated array
# *                 will be stored
# *  - size: number of items in the returned raw fingerprint
# *
# * Returns:
# *  - 0 on error, 1 on success
# */
#CHROMAPRINT_API int chromaprint_get_raw_fingerprint(ChromaprintContext *ctx, void **fingerprint, int *size);

        sub chromaprint_get_raw_fingerprint(Context $ctx, Pointer[Pointer] $fingerprint, Pointer[int32] $size ) is native(LIB) returns int32 { * }

#-From /usr/include/chromaprint.h:213
#/**
# * Compress and optionally base64-encode a raw fingerprint
# *
# * The caller is responsible for freeing the returned pointer using
# * chromaprint_dealloc().
# *
# * Parameters:
# *  - fp: pointer to an array of 32-bit integers representing the raw
# *        fingerprint to be encoded
# *  - size: number of items in the raw fingerprint
# *  - algorithm: Chromaprint algorithm version which was used to generate the
# *               raw fingerprint
# *  - encoded_fp: pointer to a pointer, where the encoded fingerprint will be
# *                stored
# *  - encoded_size: size of the encoded fingerprint in bytes
# *  - base64: Whether to return binary data or base64-encoded ASCII data. The
# *            compressed fingerprint will be encoded using base64 with the
# *            URL-safe scheme if you set this parameter to 1. It will return
# *            binary data if it's 0.
# *
# * Returns:
# *  - 0 on error, 1 on success
# */
#CHROMAPRINT_API int chromaprint_encode_fingerprint(const void *fp, int size, int algorithm, void **encoded_fp, int *encoded_size, int base64);

        sub chromaprint_encode_fingerprint(Pointer $fp, int32 $size, int32 $algorithm, Pointer[Pointer] $encoded_fp, Pointer[int32] $encoded_size, int32 $base64 ) is native(LIB) returns int32 { * }

#-From /usr/include/chromaprint.h:236
#/**
# * Uncompress and optionally base64-decode an encoded fingerprint
# *
# * The caller is responsible for freeing the returned pointer using
# * chromaprint_dealloc().
# *
# * Parameters:
# *  - encoded_fp: Pointer to an encoded fingerprint
# *  - encoded_size: Size of the encoded fingerprint in bytes
# *  - fp: Pointer to a pointer, where the decoded raw fingerprint (array
# *        of 32-bit integers) will be stored
# *  - size: Number of items in the returned raw fingerprint
# *  - algorithm: Chromaprint algorithm version which was used to generate the
# *               raw fingerprint
# *  - base64: Whether the encoded_fp parameter contains binary data or
# *            base64-encoded ASCII data. If 1, it will base64-decode the data
# *            before uncompressing the fingerprint.
# *
# * Returns:
# *  - 0 on error, 1 on success
# */
#CHROMAPRINT_API int chromaprint_decode_fingerprint(const void *encoded_fp, int encoded_size, void **fp, int *size, int *algorithm, int base64);

        sub chromaprint_decode_fingerprint(Pointer  $encoded_fp, int32 $encoded_size, Pointer[Pointer] $fp, Pointer[int32] $size, Pointer[int32] $algorithm, int32 $base64 ) is native(LIB) returns int32 { * }

#-From /usr/include/chromaprint.h:244
#/**
# * Free memory allocated by any function from the Chromaprint API.
# *
# * Parameters:
# *  - ptr: Pointer to be deallocated
# */
#CHROMAPRINT_API void chromaprint_dealloc(void *ptr);

        sub chromaprint_dealloc_p(Pointer $ptr ) is symbol('chromaprint_dealloc') is native(LIB) { * }

        method !dealloc(Pointer $ptr) {
            chromaprint_dealloc_p($ptr);
        }
    }

    has Context $!context handles <fingerprint free>;

    has Bool $!started = False;

    submethod BUILD(Int :$silence-threshold, Algorithm :$algorithm = Test2) {
        $!context = Context.new(:$algorithm);

        if $silence-threshold.defined {
            $!context.silence-threshold($silence-threshold);
        }
    }

    has Int $!samplerate;
    has Int $!channels;

    method start($!samplerate, $!channels) returns Bool {
        $!started = $!context.start($!samplerate, $!channels);
    }

    class X::NotStarted is Exception {
        has Str $.message = "start() must be called before feed";
    }

    proto method feed(|c) { * }

    multi method feed(CArray $data, Int $frames) returns Bool {
        if not $!started {
            X::NotStarted.new.throw;
        }
        $!context.feed($data, $frames);
    }

    multi method feed(@frames) returns Bool {
        if not $!started {
            X::NotStarted.new.throw;
        }
        my $carray = copy-to-carray(@frames, int16);
        my $frames = (@frames.elems / $!channels).Int;
        $!context.feed($carray, $frames);
    }

    method finish() returns Bool {
        if not $!started {
            X::NotStarted.new.throw;
        }
        my $rc = $!context.finish;
        if $rc {
            $!started = False;
        }
        $rc;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
