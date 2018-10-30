use v6.c;

=begin pod

=head1 NAME

Audio::Convert::Samplerate - perform samplerate conversion on audio data

=head1 SYNOPSIS

=begin code

    use Audio::Convert::Samplerate;
    use Audio::Sndfile;

    my $test-file-in = "t/data/1sec-chirp-22050.wav";
    my $test-file-out = "test-out.wav";
    my $bufsize = 4192;
    my $ratio = 2;

    my Audio::Sndfile $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r);
    my Audio::Convert::Samplerate $conv-obj =  Audio::Convert::Samplerate.new(channels => $in-obj.channels);
    my Int $sr = ($in-obj.samplerate * $ratio).Int;

    my Audio::Sndfile $out-obj = Audio::Sndfile.new(filename   => $test-file-out, 
                                                    channels   => $in-obj.channels, 
                                                    format     => $in-obj.format,
                                                    samplerate => $sr,  :w);


    loop {
        my @data-in = $in-obj.read-int($bufsize);
        my Bool $last = (@data-in.elems != ($bufsize * $in-obj.channels));
        my @data-out = $conv-obj.process-int(@data-in, $ratio, $last);
        $out-obj.write-int(@data-out);
        last if $last;
    }

    $in-obj.close;
    $out-obj.close;

=end code

See also the C<examples> directory in the repository.

=head1 DESCRIPTION

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

It should be noted that "round-tripping" data (for example doubling
the samplerate and then halving it again,) may not always result in the
same number of samples that you started with (by a very small number
usually less than 0.2% of the samples.) This is a feature of the way
that libsamplerate works and not a bug.

=head2 METHODS

=head3 method new

    method new (Type :$type = Medium, Int :$channels = 2)

The constructor of the class.  The C<type> parameter is a value of
the enum C<Type> with one of thse values:

=item Best

=item Medium

=item Fastest 

=item OrderHold 

=item Linear

The converter types are described in detail at L<http://www.mega-nerd.com/SRC/api_misc.html#Converters>

The default for C<type> is C<Medium> which has a balance of quality of
speed suitable for general application.

The C<channels> should represent the number of channels present in the
input audio for the processing methods.  It defaults to 2 but should always
represent the correct value or the conversion will be incorrect.

=head3 method samplerate-version

    method samplerate-version ( --> Version)

This returns a L<Version> object that represents the version of the
underlying library.  The author of the library seems to use their own
scheme for versioning so this is probably not suitable for direct
comparison.

=head3 method process-float

    method process-float (@items, Num $src-ratio, Bool $last = False --> Array)

Perform sample rate conversion on the 32 bit floating point numbers
provided as an array, to the ratio C<$src-ratio> returning an array of
the processed samples.  The C<$last> should be set to True when this is
the last batch of samples to be processed so it can return any buffered
samples.

This will throw an L<X:InvalidRatio> if the ratio supplied was found to
be invalid, or a L<X::ConvertError> if there was some other problem with
the conversion.

=head3 method process-short

    method process-short (@items, Num $src-ratio, Bool $last = False --> Array)

Perform sample rate conversion on the 16 bit integers provided as an
array, to the ratio C<$src-ratio> returning an array of the processed
samples.  The C<$last> should be set to True when this is the last batch
of samples to be processed so it can return any buffered samples.

This will throw an L<X:InvalidRatio> if the ratio supplied was found to
be invalid, or a L<X::ConvertError> if there was some other problem with
the conversion.

=head3 method process-int

    method process-int (@items, Num $src-ratio, Bool $last = False --> Array)

Perform sample rate conversion on the 32 bit integers provided as an
array, to the ratio C<$src-ratio> returning an array of the processed
samples.  The C<$last> should be set to True when this is the last batch
of samples to be processed so it can return any buffered samples.

This will throw an L<X:InvalidRatio> if the ratio supplied was found to
be invalid, or a L<X::ConvertError> if there was some other problem with
the conversion.

=head3 method process

    multi method process (CArray[num32] $data-in, Int $input-frames, Num $src-ratio, Bool $last = False --> RawProcess)
    multi method process (CArray[int16] $data-in, Int $input-frames, Num $src-ratio, Bool $last = False --> RawProcess)
    multi method process (CArray[int32] $data-in, Int $input-frames, Num $src-ratio, Bool $last = False --> RawProcess)

Perform sample rate conversion on the samples in the appropriately typed
native array which should contain the data for C<$input-frames> frames
(that is the number of samples divided by the number of channels in the
data,)  to the ratio C<$src-ratio>. The C<$last> should be set to True
when this is the last batch of samples to be processed so it can return
any buffered samples.

The return value is a two element array with a L<CArray> as the first
element and the number of B<frames> represented as the second.

This will throw an L<X:InvalidRatio> if the ratio supplied was found to
be invalid, or a L<X::ConvertError> if there was some other problem with
the conversion.

=head3 method is-valid-ratio

    method is-valid-ratio (Num() $ratio --> Bool)

Returns a Bool to indicate whether the supplied conversion ratio is valid.
This may be used if taking a ratio from user input as the process
methods will throw an exception if supplied an invalid ratio.

=end pod

class Audio::Convert::Samplerate:ver<0.0.7>:auth<github:jonathanstowe> {
    use NativeCall;
    use NativeHelpers::Array;

    subset RawProcess of Array where  ($_.elems == 2 ) && ($_[0] ~~ CArray) && ($_[1] ~~ Int);

    enum Type <Best Medium Fastest OrderHold Linear>;

    class X::ConvertError is Exception {
        has Int $.error-code = 0;

        sub src_strerror(int32 $error) returns Str is native('samplerate',v0) { * }

        method message() returns Str {
            src_strerror($!error-code);
        }
    }

    class X::InvalidRatio is Exception {
        has Num $.ratio is required;

        method message() returns Str {
            "The convertion ratio { $!ratio } is not valid";
        }
    }

    class Data is repr('CStruct') {
        has CArray[num32] $.data-in;
        has CArray[num32] $.data-out;
        has int64 $.input-frames;
        has int64 $.output-frames;
        has int64 $.input-frames-used;
        has int64 $.output-frames-gen;
        has int32 $.end-of-input;
        has num64 $.src-ratio;

        submethod BUILD(CArray[num32] :$data-in!, Int :$input-frames!, Num() :$src-ratio!, Int :$channels = 2, Bool :$last = False) {
            $!data-in := $data-in;
            $!input-frames = $input-frames;
            $!src-ratio = $src-ratio;
            my CArray[num32] $data-out := CArray[num32].new;
            $!output-frames = ($input-frames * $src-ratio).Int + 10;
            $data-out[$!output-frames * $channels] = Num(0);
            $!data-out := $data-out;
            $!input-frames-used = 0;
            $!output-frames-gen = 0;
            $!end-of-input = $last ?? 1 !! 0;
        }
    }

    class State is repr('CPointer') {

        sub src_new(int32 $converter-type, int32 $channels, int32 $error) returns State is native('samplerate',v0) { * }

        method new(Type $type, Int $channels) returns State {
            my Int $error = 0;
            my $state = src_new($type.Int, $channels, $error);

            if not $state.defined {
                X::ConvertError.new(error-code => $error).throw;
            }

            $state;
        }

        sub src_process(State $st, Data $d is rw) returns int32 is native('samplerate',v0) { * }

        multi method process(Data $data is rw) returns Data {
            my $rc = src_process(self, $data);

            if $rc != 0 {
                X::ConvertError.new(error-code => $rc).throw;
            }
            $data;
        }

        # put this in here as it simplifies matters
        sub src_is_valid_ratio (num64 $ratio) returns int32 is native('samplerate',v0) { * }

        method is-valid-ratio(Num $ratio) returns Bool {
            if src_is_valid_ratio($ratio) {
                True;
            }
            else {
                False;
            }
        }

        sub src_set_ratio(State $state, num64 $new_ratio) returns int32 is native('samplerate',v0) { * }

        method set-ratio(Num $new-ratio) {
            my $rc = src_set_ratio(self, $new-ratio);

            if $rc != 0 {
                X::ConvertError.new(error-code => $rc).throw;
            }
        }

        sub src_reset(State) returns int32 is native('samplerate',v0) { * }

        method reset() {
            my $rc = src_reset(self);

            if $rc != 0 {
                X::ConvertError.new(error-code => $rc).throw;
            }
        }

        sub src_delete(State) is native('samplerate',v0) { * }

        method DESTROY() {
            src_delete(self);
        }

    }


    has Type  $!type;
    has Int   $!channels;
    has State $!state handles <is-valid-ratio>;

    submethod BUILD(Type :$!type = Medium, Int :$!channels = 2) {
        $!state = State.new($!type, $!channels);
    }

    sub src_get_version() returns Str is native('samplerate',v0) { * }

    method samplerate-version() returns Version {
        my $v = src_get_version();
        Version.new($v);
    }

    multi method process(CArray[num32] $data-in, Int $input-frames, Num() $src-ratio, Bool $last = False) returns RawProcess {

        if not self.is-valid-ratio($src-ratio) {
            X::InvalidRatio.new.throw;
        }


        my Data $data = Data.new(:$data-in, :$input-frames, :$last, :$src-ratio);

        $data = $!state.process($data);
        refresh($data);

        [ $data.data-out, $data.output-frames-gen ];
    }

    method !process-other(Mu $type, CArray $data-in, Int $input-frames, Num() $src-ratio, Bool $last, &to, &from) returns RawProcess {
        my CArray[num32] $new-data = CArray[num32].new;
        my Int $total-frames = ($input-frames * $!channels).Int;
        $new-data[$total-frames] = Num(0);
        &to($data-in, $new-data, $total-frames);
        (my $float-out, my $frames-out ) = self.process($new-data, $input-frames, $src-ratio, $last).list;
        my CArray $int-out = CArray[$type].new;
        my Int $total-out = ($frames-out * $!channels).Int;
        $int-out[$total-out] = 0;
        &from($float-out, $int-out, $total-out);
        [ $int-out, $frames-out ]
    }

    multi method process(CArray[int16] $data-in, Int $input-frames, Num() $src-ratio, Bool $last = False) returns RawProcess {
        self!process-other(int16, $data-in, $input-frames, $src-ratio, $last, &src_short_to_float_array, &src_float_to_short_array);
    }

    multi method process(CArray[int32] $data-in, Int $input-frames, Num() $src-ratio, Bool $last = False) returns RawProcess {
        self!process-other(int32, $data-in, $input-frames, $src-ratio, $last, &src_int_to_float_array, &src_float_to_int_array);
    }

    method !process-array(Mu $type, @items, Num() $src-ratio, Bool $last = False) returns Array {
        my CArray $carray = copy-to-carray(@items, $type);
        my $frames = (@items.elems / $!channels).Int;
        my $ret = self.process($carray, $frames, $src-ratio, $last);
        copy-to-array($ret[0], $ret[1] * $!channels);
    }
    method process-float(@items, Num() $src-ratio, Bool $last = False) returns Array {
        self!process-array(num32, @items, $src-ratio, $last);
    }
    method process-short(@items, Num() $src-ratio, Bool $last = False) returns Array {
        self!process-array(int16, @items, $src-ratio, $last);
    }
    method process-int(@items, Num() $src-ratio, Bool $last = False) returns Array {
        self!process-array(int32, @items, $src-ratio, $last);
    }

    sub src_short_to_float_array(CArray[int16] $in, CArray[num32] $out, int32 $len) is native('samplerate',v0) { * }
    sub src_float_to_short_array(CArray[num32] $in, CArray[int16] $out, int32 $len) is native('samplerate',v0) { * }

    sub src_int_to_float_array(CArray[int32] $in, CArray[num32] $out, int32 $len) is native('samplerate',v0) { * }
    sub src_float_to_int_array(CArray[num32] $in, CArray[int32] $out, int32 $len) is native('samplerate',v0) { * }

}

# vim: expandtab shiftwidth=4 ft=perl6
