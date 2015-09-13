#!perl6

use v6;
use lib 'lib';
use Test;

use Audio::Sndfile;

my @tests = (
                {
                    type => Audio::Sndfile::Info::CAF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.caf",
                    format => 1572870,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::W64,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.w64",
                    format => 720902,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::W64,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.w64",
                    format => 720902,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.aifc",
                    format => 131078,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.aif",
                    format => 131078,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AU,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.au",
                    format => 196614,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::WAV,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.wav",
                    format => 65542,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::W64,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.w64",
                    format => 720902,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.aiff",
                    format => 131078,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::WAV,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.wav",
                    format => 65542,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.aifc",
                    format => 131078,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.aiff",
                    format => 131078,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.aif",
                    format => 131078,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AU,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.au",
                    format => 196614,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.aif",
                    format => 131078,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AU,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.au",
                    format => 196614,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::WAV,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.wav",
                    format => 65542,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::CAF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.caf",
                    format => 1572870,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.aiff",
                    format => 131078,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::CAF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.caf",
                    format => 1572870,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.aifc",
                    format => 131078,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                }
        );

for @tests -> $test {
    my Audio::Sndfile $obj;
    lives-ok { $obj = Audio::Sndfile.new(filename => $test<filename>, :r) }, "get " ~ $test<filename>;
    is($obj.format, $test<format>, "got the right format");
    is($obj.frames, $test<frames>, "got the right number of frames");
    is($obj.seekable, $test<seekable>, "seekable");
    is($obj.samplerate, $test<sample-rate>, "got the right sample rate");
    is($obj.channels, $test<channels>, "got the right number of channels");
    is($obj.sections, $test<sections>, "got the right sections");
    ok($obj ~~ $test<type>, "smart match object against " ~ $test<type>);

    my @data;

    lives-ok { @data = $obj.read-short(100) }, "read 100 frames with read-short";
    is($obj.error-number, 0, "no error");
    is(@data.elems, 100 * $obj.channels, "got the correct number of elements");
    ok(@data[0] ~~ Int, "and it is an Int");
    ok(@data[0].defined, "and it is actually defined");
    lives-ok { @data = $obj.read-int(100) }, "read 100 frames with read-int";
    is($obj.error-number, 0, "no error");
    is(@data.elems, 100 * $obj.channels, "got the correct number of elements");
    ok(@data[0] ~~ Int, "and it is an Int");
    ok(@data[0].defined, "and it is actually defined");
    lives-ok { @data = $obj.read-float(100) }, "read 100 frames with read-float";
    is($obj.error-number, 0, "no error");
    is(@data.elems, 100 * $obj.channels, "got the correct number of elements");
    ok(@data[0] ~~ Num, "and it is a Num");
    ok(!(@data[0] ~~ NaN), "and it isn't NaN");
    ok(@data[0].defined, "and it is actually defined");
    lives-ok { @data = $obj.read-double(100) }, "read 100 frames with read-double";
    is($obj.error-number, 0, "no error");
    is(@data.elems, 100 * $obj.channels, "got the correct number of elements");
    ok(@data[0] ~~ Num, "and it is a Num");
    ok(!(@data[0] ~~ NaN), "and it isn't NaN");
    ok(@data[0].defined, "and it is actually defined");

    lives-ok { $obj.close }, "close that";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
