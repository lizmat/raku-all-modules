NAME
====

Audio::Convert::Samplerate - perform samplerate conversion on audio data

SYNOPSIS
========

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

See also the `examples` directory in the repository.

DESCRIPTION
===========

This provides a mechanism for doing sample rate conversion of PCM audio data using libsamplerate (http://www.mega-nerd.com/libsamplerate/) the implementation of which is both fairly quick and accurate.

The interface is fairly simple, providing methods to work with native C arrays where the raw speed is important as well as perl arrays where further processing is required on the data.

The native library is designed to work only with 32 bit floating point samples so working with other sample types requires some conversion and a subsequent small loss of efficiency (although the int and short to float conversions are done in C code and so are reasonably quick.) There is no support for 64 bit int (long) or float (double) data.

It should be noted that "round-tripping" data (for example doubling the samplerate and then halving it again,) may not always result in the same number of samples that you started with (by a very small number usually less than 0.2% of the samples.) This is a feature of the way that libsamplerate works and not a bug.

METHODS
-------

### method new

    method new (Type :$type = Medium, Int :$channels = 2)

The constructor of the class. The `type` parameter is a value of the enum `Type` with one of thse values:

  * Best

  * Medium

  * Fastest 

  * OrderHold 

  * Linear

The converter types are described in detail at [http://www.mega-nerd.com/SRC/api_misc.html#Converters](http://www.mega-nerd.com/SRC/api_misc.html#Converters)

The default for `type` is `Medium` which has a balance of quality of speed suitable for general application.

The `channels` should represent the number of channels present in the input audio for the processing methods. It defaults to 2 but should always represent the correct value or the conversion will be incorrect.

### method samplerate-version

    method samplerate-version ( --> Version)

This returns a [Version](Version) object that represents the version of the underlying library. The author of the library seems to use their own scheme for versioning so this is probably not suitable for direct comparison.

### method process-float

    method process-float (@items, Num $src-ratio, Bool $last = False --> Array)

Perform sample rate conversion on the 32 bit floating point numbers provided as an array, to the ratio `$src-ratio` returning an array of the processed samples. The `$last` should be set to True when this is the last batch of samples to be processed so it can return any buffered samples.

This will throw an [X:InvalidRatio](X:InvalidRatio) if the ratio supplied was found to be invalid, or a [X::ConvertError](X::ConvertError) if there was some other problem with the conversion.

### method process-short

    method process-short (@items, Num $src-ratio, Bool $last = False --> Array)

Perform sample rate conversion on the 16 bit integers provided as an array, to the ratio `$src-ratio` returning an array of the processed samples. The `$last` should be set to True when this is the last batch of samples to be processed so it can return any buffered samples.

This will throw an [X:InvalidRatio](X:InvalidRatio) if the ratio supplied was found to be invalid, or a [X::ConvertError](X::ConvertError) if there was some other problem with the conversion.

### method process-int

    method process-int (@items, Num $src-ratio, Bool $last = False --> Array)

Perform sample rate conversion on the 32 bit integers provided as an array, to the ratio `$src-ratio` returning an array of the processed samples. The `$last` should be set to True when this is the last batch of samples to be processed so it can return any buffered samples.

This will throw an [X:InvalidRatio](X:InvalidRatio) if the ratio supplied was found to be invalid, or a [X::ConvertError](X::ConvertError) if there was some other problem with the conversion.

### method process

    multi method process (CArray[num32] $data-in, Int $input-frames, Num $src-ratio, Bool $last = False --> RawProcess)
    multi method process (CArray[int16] $data-in, Int $input-frames, Num $src-ratio, Bool $last = False --> RawProcess)
    multi method process (CArray[int32] $data-in, Int $input-frames, Num $src-ratio, Bool $last = False --> RawProcess)

Perform sample rate conversion on the samples in the appropriately typed native array which should contain the data for `$input-frames` frames (that is the number of samples divided by the number of channels in the data,) to the ratio `$src-ratio`. The `$last` should be set to True when this is the last batch of samples to be processed so it can return any buffered samples.

The return value is a two element array with a [CArray](CArray) as the first element and the number of **frames** represented as the second.

This will throw an [X:InvalidRatio](X:InvalidRatio) if the ratio supplied was found to be invalid, or a [X::ConvertError](X::ConvertError) if there was some other problem with the conversion.

### method is-valid-ratio

    method is-valid-ratio (Num() $ratio --> Bool)

Returns a Bool to indicate whether the supplied conversion ratio is valid. This may be used if taking a ratio from user input as the process methods will throw an exception if supplied an invalid ratio.
