#!perl6

use v6;
use lib 'lib';
use Test;
use Shell::Command;

use Audio::Sndfile;

my $test-output = "t/test-output".IO;

$test-output.mkdir unless $test-output.d;

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

throws-like { my $obj = Audio::Sndfile.new(filename => "ook.wav", :w) }, "invalid format supplied to :w";

for @tests.pick(*) -> $file {
    my $basename = $file<filename>.IO.basename;

    my $obj = Audio::Sndfile.new(filename => $file<filename>, :r);

    my $cinfo;
    lives-ok { $cinfo = $obj.clone-info }, "clone-info for " ~ $file<filename>;
    ok($cinfo.format-check, "format-check on clone");
    is($cinfo.samplerate, $obj.samplerate, "samplerate the same");
    is($cinfo.channels, $obj.channels, "channels the same");
    is($cinfo.format, $obj.format, "format the same");

    my @ints = $obj.read-int(100);
    my $int-name = $test-output.child("int-$basename");

    my $i;

    my $int-obj;
    lives-ok { $int-obj = Audio::Sndfile.new(filename => $int-name, info => $cinfo, :w) }, "open $int-name for writing";
    lives-ok { $i = $int-obj.write-int(@ints) }, "write-int";
    is($i, 100, "and it did write 100 frames");
    lives-ok { $int-obj.close }, "close that file to reopen";
    lives-ok { $int-obj = Audio::Sndfile.new(filename => $int-name, :r) }, "re-open $int-name for reading";
    is($int-obj.format, $obj.format, "format is the same as we expected");
    is($int-obj.channels, $obj.channels, "channels is what we expected");
    is($int-obj.frames, 100, "and it has 100 frames");
    my @read-ints = $int-obj.read-int(100);
    ok(@read-ints ~~ @ints, "and we got back the ints we expected");
    $int-obj.close;


    my @shorts = $obj.read-short(100);
    my $short-name = $test-output.child("short-$basename");
    my $short-obj;
    lives-ok { $short-obj = Audio::Sndfile.new(filename => $short-name, info => $cinfo, :w) }, "open $short-name for writing";
    lives-ok { $i = $short-obj.write-short(@shorts) }, "write-short";
    is($i, 100, "and it did write 100 frames");
    lives-ok { $short-obj.close }, "close that file to reopen";
    lives-ok { $short-obj = Audio::Sndfile.new(filename => $short-name, :r) }, "re-open $short-name for reading";
    is($short-obj.format, $obj.format, "format is the same as we expected");
    is($short-obj.channels, $obj.channels, "channels is what we expected");
    is($short-obj.frames, 100, "and it has 100 frames");
    my @read-shorts = $short-obj.read-short(100);
    ok(@read-shorts ~~ @shorts, "and we got back the shorts we expected");
    $short-obj.close;

    my @floats = $obj.read-float(100);
    my $float-name = $test-output.child("float-$basename");
    my $float-obj;
    lives-ok { $float-obj = Audio::Sndfile.new(filename => $float-name, info => $cinfo, :w) }, "open $float-name for writing";
    todo("Bug with CArray[num32] - see (https://rt.perl.org/Ticket/Display.html?id=125408)", 8);
    lives-ok { $i = $float-obj.write-float(@floats) }, "write-float";
    is($i, 100, "and it did write 100 frames");
    lives-ok { $float-obj.close }, "close that file to reopen";
    lives-ok { $float-obj = Audio::Sndfile.new(filename => $float-name, :r) }, "re-open $float-name for reading";
    is($float-obj.format, $obj.format, "format is the same as we expected");
    is($float-obj.channels, $obj.channels, "channels is what we expected");
    is($float-obj.frames, 100, "and it has 100 frames");
    my @read-floats = $float-obj.read-float(100);
    ok(@read-floats ~~ @floats, "and we got back the floats we expected");
    $float-obj.close;
    my @doubles = $obj.read-double(100);
    my $double-name = $test-output.child("double-$basename");
    my $double-obj;
    lives-ok { $double-obj = Audio::Sndfile.new(filename => $double-name, info => $cinfo, :w) }, "open $double-name for writing";
    todo("Bug with CArray[num64] - (see https://rt.perl.org/Ticket/Display.html?id=125408 )", 8);
    lives-ok { $i = $double-obj.write-double(@doubles) }, "write-double";
    is($i, 100, "and it did write 100 frames");
    lives-ok { $double-obj.close }, "close that file to reopen";
    lives-ok { $double-obj = Audio::Sndfile.new(filename => $double-name, :r) }, "re-open $double-name for reading";
    is($double-obj.format, $obj.format, "format is the same as we expected");
    is($double-obj.channels, $obj.channels, "channels is what we expected");
    is($double-obj.frames, 100, "and it has 100 frames");
    my @read-doubles = $double-obj.read-double(100);
    ok(@read-doubles ~~ @doubles, "and we got back the doubles we expected");
    $double-obj.close;
    $obj.close;
}

done;

END {
    rm_rf $test-output.Str;
}

# vim: expandtab shiftwidth=4 ft=perl6
