use v6.c;

use NativeCall;

=begin pod

=head1 NAME

Audio::Sndfile - read/write audio data via libsndfile

=head1 SYNOPSIS

=begin code

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

=end code

Other examples are available in the "examples" sub-directory of the
repository.

=head1 DESCRIPTION

This library provides a mechanism to read and write audio data files in
various formats by using the API provided by libsndfile.

A full list of the formats it is able to work with can be found at:

http://www.mega-nerd.com/libsndfile/#Features

if you need to work with formats that aren't listed then you will need
to find another library.

The interface presented is slightly simplified with regard to that of
libsndfile and whilst it does nearly everything I need it do, I have
opted to release the most useful functionality early and progressively
add features as it becomes clear how they should be implemented.

As of the first release, the methods provided for writing audio data do
not constrain the items to the range expected by the method.  If out of
range data is supplied wrapping will occur which may lead to unexpected
results.

=head3 FRAMES vs ITEMS

In the description of the L<methods|#METHODS> below a 'frame' refers to
one or more items ( that is  the number of channels in the audio data.)
The frame data is interleaved per channel consecutively and must always
have a number of items that is a multiple of the number of channels.
The read methods will always return a number of items that is the
multiple of number of channels - thus you can determine if you got the
number back that you requested with something like:

     @frames.elems == ( $num-channels * $frames-requested)

The write methods will throw an exception if supplied with an array that
isn't some multiple of the number of channels and will always return
the number of 'frames' written.

There are no methods provided for interleaving or de-interleaving frame
data as Perl's list methods (e.g. C<zip> or C<rotor>) are perfect for
this task.

=head2 METHODS

=head3 new

    method new(Audio::Sndfile:U: Str :$filename!, :r)

The C<:r> adverb opens the specified file for reading.  If the file
can't be opened or there is some other problem with it (such as it not
being a supported format,) then an exception will be thrown.

    method new(Audio::Sndfile:U: Str :$filename!, :w, Audio::Sndfile::Info :$info) 
    method new(Audio::Sndfile:U: Str :$filename!, :w, *%info)

The C<:w> adverb opens the specified file for writing.  It requires
either an existing valid L<Audio::Sndfile::Info> supplied as the C<info>
named parameter, or attributes that will be passed to the constructor of
L<Audio::Sndfile::Info>.  If the file cannot be opened for some reason
or the resulting  L<Audio::Sndfile::Info> is incomplete or invalid an
exception will be thrown.

The info requires the attributes C<channels>, C<format>,
C<samplerate>. If copying or converting an existing file opened for
reading the L<clone-info|#clone-info> method can be used to obtain a
valid L<Audio::Sndfile::Info>.

=head3 info

This is an accessor to the L<Audio::Sndfile::Info> for the opened file. It is
read-only as it doesn't make sense to change the info after the file has been
opened.

There are several accessors delegated to this object:

=item format 

The format of the file formed by the bitwise or of C<type>, C<sub-type>
and C<endian>

=item channels 

The number of channels in the file.

=item samplerate 

The sample rate of the file as an Int (e.g. 44100, 48000).

=item frames 

The number of frames in the file.  This only makes sense when the file
is opened for reading.

=item sections 

=item seekable 

A Bool indicating whether the open file is seekable, this will be True
for most regular files and False for special files such as a pipe,
however as there currently isn't any easy way to open other than a
regular file this may not be useful.

=item type 

A value of the enum L<Audio::Sndfile::Info::Format> indicating the major
format of the file (e.g. WAV,) this is bitwise or-ed with the C<sub-type>
and C<endian> to create C<format> (which is what is used by the underlying
library functions.)

=item sub-type 

A value of the enum L<Audio::Sndfile::Info::Subformat> indicating the
minor format or sample encoding of the file (e.g PCM_16, FLOAT, ) this
is bitwise or-ed with the C<type> and C<endian> to create C<format>

=item endian 

A value of the enum L<Audio::Sndfile::Info::End> that indicate the
endian-ness of the sample data.  This is bitwise or-ed with C<type>
and C<sub-type> to provide C<format>.

=item duration

A L<Duration> object that describes the duration of the file in (possibly
fractional) seconds.  This probably only makes sense for files opened
for reading.

=head3 library-version

    method library-version(Audio::Sndfile:D: ) returns Str

Returns a string representation of the version reported by libsndfile.

=head3 close 

    method close(Audio::Sndfile:D:) returns Int

This closes the file stream for the opened file. Attempting to write or
read the object after this has been called is an error.

=head3 error-number 

    method error-number(Audio::Sndfile:D:) returns Int

This returns non-zero if there was an error in the last read, write
or open operation. The actual error message can be obtained with
L<error|#error> below.

=head3 error 

    method error(Audio::Sndfile:D:) returns Str

This will return the string describing the last error if
L<error-number|#error-number> was non-zero or 'No Error' otherwise.

=head3 sync

    method sync(Audio::Sndfile:D:) returns Int

If the file is opened for writing then any buffered data will be flushed
to disk.  If the file was opened for reading it does nothing.

=head3 read-short

    multi method read-short(Audio::Sndfile:D: Int $frames) returns Array[int16]
    multi method read-short(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[int16], Int]

This returns an array of size C<$frames> * $num-channels of 16 bit
integers from the opened file.  The returned array may be empty or
shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array containing the raw CArray
returned from the underlying library and the number of frames.  This is for convenience
(and efficiency ) where the data is going to be passed directly to another native libray
function.

=head3 write-short

    multi method write-short(Audio::Sndfile:D: @frames) returns Int
    multi method write-short(Audio::Sndfile:D: CArray[int16] $frames-in, Int $frames) returns Int

This writes the array @frames of 16 bit integers to the file. @frames
must have a number of elements that is a multiple of the number of
channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error
will occur.

If the values are outside the range for an int16 then wrapping will occur.

The second multi is for the convenience of applications which may have obtained their data
from some native function.

=head3 read-int

    multi method read-int(Audio::Sndfile:D: Int $frames) returns Array[Int]
    multi method read-int(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[int32], Int]

This returns an array of size C<$frames> * $num-channels of 32 bit
integers from the opened file.  The returned array may be empty or
shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array
containing the raw CArray returned from the underlying library and the
number of frames.  This is for convenience (and efficiency ) where the
data is going to be passed directly to another native libray function.

=head3 write-int

    multi method write-int(Audio::Sndfile:D: @frames) returns Int
    multi method write-int(Audio::Sndfile:D: CArray[int32] $frames-in, Int $frames) returns Int

This writes the array @frames of 32 bit integers to the file. @frames
must have a number of elements that is a multiple of the number of
channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error
will occur.

If the values are outside the range for an int32 then wrapping will occur.

The second multi is for the convenience of applications which may have
obtained their data from some native function.

=head3 read-float

    multi method read-float(Audio::Sndfile:D: Int $frames) returns Array[num32]
    multi method read-float(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[num32], Int]

This returns an array of size C<$frames> * $num-channels of 32 bit
floating point numbers from the opened file.  The returned array may be
empty or shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array
containing the raw CArray returned from the underlying library and the
number of frames.  This is for convenience (and efficiency ) where the
data is going to be passed directly to another native libray function.

=head3 write-float

    multi method write-float(Audio::Sndfile:D: @frames) returns Int
    multi method write-float(Audio::Sndfile:D: CArray[num32] $frames-in, Int $frames) returns Int

This writes the array @frames of 32 bit floating point numbers to the
file. @frames must have a number of elements that is a multiple of the
number of channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error
will occur.

If the values are outside the range for a num32 then wrapping will occur.

The second multi is for the convenience of applications which may have
obtained their data from some native function.

=head3 read-double

    multi method read-double(Audio::Sndfile:D: Int $frames) returns Array[num64]
    multi method read-double(Audio::Sndfile:D: Int $frames, :$raw!) returns [CArray[num64], Int]

This returns an array of size C<$frames> * $num-channels of 64 bit
floating point numbers from the opened file.  The returned array may be
empty or shorter than expected if there is no more data to read.

With the the ':raw' adverb specified it will return a two element array
containing the raw CArray returned from the underlying library and the
number of frames.  This is for convenience (and efficiency ) where the
data is going to be passed directly to another native libray function.

=head3 write-double

    multi method write-double(Audio::Sndfile:D: @frames) returns Int
    multi method write-double(Audio::Sndfile:D: CArray[num64] $frames-in, Int $frames) returns Int

This writes the array @frames of 64 bit floating point numbers to the
file. @frames must have a number of elements that is a multiple of the
number of channels or an exception will be thrown.

If the files isn't opened for writing or if it has been closed an error
will occur.

If the values are outside the range for a num64 then wrapping will occur.

As of the time of the initial release, this may fail if the frame data was
directly retrieved via L<read-double|#read-double> due to an infelicity in
the runtime, this should be fixed at some point but can be worked around by
copying the values.

The second multi is for the convenience of applications which may have obtained their data
from some native function.

=head3 clone-info

    method clone-info(Audio::Sndfile:D: ) returns Audio::Sndfile::Info

This returns a new L<Audio::Sndfile::Info> based on the details of the
current file suitable for being passed to L<new|#new> for instance when
copying or converting the file.

=end pod

class Audio::Sndfile:ver<0.0.10>:auth<github:jonathanstowe> {

    subset RawEncode of Array where  ($_.elems == 2 ) && ($_[0] ~~ CArray) && ($_[1] ~~ Int);

    use Audio::Sndfile::Info;

    # The opaque type returned from open
    my class File is repr('CPointer') {

        sub sf_close(File $file) returns int32 is native('sndfile',v1) { * }

        method close() {
            sf_close(self);
        }

        sub sf_error(File $file) returns int32 is native('sndfile',v1) { * }

        method error-number() {
            sf_error(self);
        }
        sub sf_strerror(File $file) returns Str is native('sndfile',v1) { * }

        method error() {
            sf_strerror(self);
        }

        multi method read-read(Int $frames, Audio::Sndfile::Info $info, &read-sub, Mu:U $type, :$raw!) returns RawEncode {

            my $buff = CArray[$type].new;

            $buff[$frames * $info.channels] = $type ~~ Num ?? Num(0) !! Int(0);

            my $rc = &read-sub(self, $buff, $frames);

            [ $buff, $rc ];
        }

        multi method read-read(Int $frames, Audio::Sndfile::Info $info, &read-sub, Mu:U $type ) returns Array {

            my ($buff, $rc ) =  self.read-read($frames, $info, &read-sub, $type, :raw).list;
            my @tmp_arr =  (^($rc * $info.channels)).map({ $buff[$_] });
            
            @tmp_arr;
        }

        multi method write-write(Audio::Sndfile::Info $info, &write-sub, Mu:U $type, @items) returns Int {

            my $buff = CArray[$type].new;
            for ^@items.elems -> $i {
                $buff[$i] = @items[$i];
            }
            my Int $frames = (@items.elems / $info.channels).Int;
            self.write-write(&write-sub, $buff, $frames);
        }

        multi method write-write(&write-sub, CArray $frames-in, Int $frames ) returns Int {
            &write-sub(self, $frames-in, $frames);
        }

        sub sf_readf_short(File , CArray[int16] is rw, int64) returns int64 is native('sndfile',v1) { * }


        multi method read-short(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self.read-read($frames, $info, &sf_readf_short, int16);
        }
        multi method read-short(Int $frames, Audio::Sndfile::Info $info, :$raw!) returns RawEncode {
            self.read-read($frames, $info, &sf_readf_short, int16, :raw);
        }

        sub sf_writef_short(File , CArray[int16], int64) returns int64 is native('sndfile',v1) { * }

        multi method write-short(Audio::Sndfile::Info $info, @items ) returns Int {
            self.write-write($info, &sf_writef_short, int16, @items);
        }
        multi method write-short(CArray[int16] $frames-in, Int $frames  ) returns Int {
            self.write-write(&sf_writef_short, $frames-in, $frames);
        }

        sub sf_readf_int(File , CArray[int32], int64) returns int64 is native('sndfile',v1) { * }

        multi method read-int(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self.read-read($frames, $info, &sf_readf_int, int32);
        }
        multi method read-int(Int $frames, Audio::Sndfile::Info $info, :$raw!) returns RawEncode {
            self.read-read($frames, $info, &sf_readf_int, int32, :raw);
        }

        sub sf_writef_int(File , CArray[int32], int64) returns int64 is native('sndfile',v1) { * }

        multi method write-int(Audio::Sndfile::Info $info, @items ) returns Int {
            self.write-write($info, &sf_writef_int, int32, @items);
        }
        multi method write-int(CArray[int32] $frames-in, Int $frames) returns Int {
            self.write-write(&sf_writef_int, $frames-in, $frames);
        }

        sub sf_readf_double(File , CArray[num64] is rw, int64) returns int64 is native('sndfile',v1) { * }

        multi method read-double(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self.read-read($frames, $info, &sf_readf_double, num64);
        }

        multi method read-double(Int $frames, Audio::Sndfile::Info $info, :$raw!) returns RawEncode {
            self.read-read($frames, $info, &sf_readf_double, num64, :raw);
        }

        sub sf_writef_double(File , CArray[num64], int64) returns int64 is native('sndfile',v1) { * }

        multi method write-double(Audio::Sndfile::Info $info, @items ) returns Int {
            self.write-write($info, &sf_writef_double, num64, @items);
        }
        multi method write-double(CArray[num64] $frames-in, Int $frames) returns Int {
            self.write-write(&sf_writef_double, $frames-in, $frames);
        }

        sub sf_readf_float(File , CArray[num32] is rw, int64) returns int64 is native('sndfile',v1) { * }

        multi method read-float(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self.read-read($frames, $info, &sf_readf_float, num32);
        }
        multi method read-float(Int $frames, Audio::Sndfile::Info $info, :$raw!) returns RawEncode {
            self.read-read($frames, $info, &sf_readf_float, num32, :raw);
        }

        sub sf_writef_float(File , CArray[num32], int64) returns int64 is native('sndfile',v1) { * }

        multi method write-float(Audio::Sndfile::Info $info, @items ) returns Int {
            self.write-write($info, &sf_writef_float, num32, @items);
        }
        multi method write-float(CArray[num32] $frames-in, Int $frames) returns Int {
            self.write-write(&sf_writef_float, $frames-in, $frames);
        }

        sub sf_write_sync(File) is native('sndfile',v1) { * }

        method sync() {
            sf_write_sync(self);
        }

    }

    enum OpenMode (:Read(0x10), :Write(0x20), :ReadWrite(0x30));

    has Str  $.filename;
    has File $!file handles <close error-number error sync>; 
    has Audio::Sndfile::Info $.info handles <format channels samplerate frames sections seekable type sub-type endian duration>;
    has OpenMode $.mode;

    sub sf_version_string() returns Str is native('sndfile',v1) { * }

    method library-version() returns Str {
        sf_version_string();
    }

    sub sf_open(Str $filename, int32 $mode, Audio::Sndfile::Info $info) returns File is native('sndfile',v1) { * }

    submethod BUILD(Str() :$!filename!, Bool :$r, Bool :$w, Bool :$rw, Audio::Sndfile::Info :$!info?,  *%info) {
        if one($r, $w, $rw ) {
            $!mode = do if $r {
                Read;
            }
            elsif $w {
                $!info //= Audio::Sndfile::Info.new(|%info);
                die "invalid format supplied to :w" if not $!info.format-check;
                Write;
            }
            else {
                ReadWrite;
            }

            $!info //= Audio::Sndfile::Info.new();

            explicitly-manage($!filename);
            $!file = sf_open($!filename, $!mode.Int, $!info);

            if $!file.error-number > 0 {
                die $!file.error;
            }
        }
        else {
            die "exactly one of ':r', ':w', ':rw' must be provided";
        }
    }

    multi method read-short(Int $frames) returns Array {
        $!file.read-short($frames, $!info);
    }
    multi method read-short(Int $frames, :$raw!) returns RawEncode {
        $!file.read-short($frames, $!info, :raw);
    }

    multi method write-short(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-short($!info, @frames);
    }
    multi method write-short(CArray[int16] $frames-in, Int $frames) returns Int {
        $!file.write-short($frames-in, $frames);
    }

    multi method read-int(Int $frames) returns Array {
        $!file.read-int($frames, $!info);
    }
    multi method read-int(Int $frames, :$raw!) returns RawEncode {
        $!file.read-int($frames, $!info, :raw);
    }
        
    multi method write-int(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-int($!info, @frames);
    }
    multi method write-int(CArray[int32] $frames-in, Int $frames) returns Int {
        $!file.write-int($frames-in, $frames);
    }

    multi method read-float(Int $frames) returns Array {
        $!file.read-float($frames, $!info);
    }
    multi method read-float(Int $frames, :$raw!) returns RawEncode {
        $!file.read-float($frames, $!info, :raw);
    }
        
    multi method write-float(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-float($!info, @frames);
    }
    multi method write-float(CArray[num32] $frames-in, Int $frames) returns Int {
        $!file.write-float($frames-in, $frames);
    }

    multi method read-double(Int $frames) returns Array {
        $!file.read-double($frames, $!info);
    }
    multi method read-double(Int $frames, :$raw!) returns RawEncode {
        $!file.read-double($frames, $!info, :raw);
    }

    multi method write-double(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-double($!info, @frames);
    }
    multi method write-double(CArray[num64] $frames-in, Int $frames) returns Int {
        $!file.write-double($frames-in, $frames);
    }

    method !assert-frame-length(@frames) {
        if (@frames.elems % $!info.channels) != 0 {
            die "items not a multiple of channels";
        }
    }

    # minimum detail required
    method clone-info() {
        Audio::Sndfile::Info.new(
                                    samplerate  => $!info.samplerate,
                                    channels    => $!info.channels,
                                    format      => $!info.format
                                );
    }

    method Numeric() {
        $!info.type;
    }

}


# vim: expandtab shiftwidth=4 ft=perl6
