#!perl6

use v6;
use Test;

use Audio::Encode::LameMP3;
# simplify by reading PCM data from file
use Audio::Sndfile;



my IO::Path $test-data = "t/data".IO;
my $test-file = $test-data.child('cw_glitch_noise15.wav').Str;

subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-short(4192);
            my ($left, $right) = uninterleave(@in-frames);
            lives-ok { $buf = $encoder.encode-short($left, $right) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            $out-fh.write($buf);
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode shorts";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-int(4192);
            my ($left, $right) = uninterleave(@in-frames);
            lives-ok { $buf = $encoder.encode-int($left, $right) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            $out-fh.write($buf);
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode ints";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-int(4192); # obviously this is not right but there is no read long
            my ($left, $right) = uninterleave(@in-frames);
            lives-ok { $buf = $encoder.encode-long($left, $right) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            $out-fh.write($buf);
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode longs";

subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-float(4192);
            my ($left, $right) = uninterleave(@in-frames);
            lives-ok { $buf = $encoder.encode-float($left, $right) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            lives-ok { $out-fh.write($buf) }, "write that out";
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode floats";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-double(4192);
            my ($left, $right) = uninterleave(@in-frames);
            lives-ok { $buf = $encoder.encode-double($left, $right) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            lives-ok { $out-fh.write($buf) }, "write that out";
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode doubles";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-short(4192);
            lives-ok { $buf = $encoder.encode-short(@in-frames) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            $out-fh.write($buf);
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode shorts (interleaved)";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-int(4192);
            lives-ok { $buf = $encoder.encode-int(@in-frames) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            $out-fh.write($buf);
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode ints (interleaved)";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-int(4192); # obviously this is not right but there is no read long
            lives-ok { $buf = $encoder.encode-long(@in-frames) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            $out-fh.write($buf);
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode longs (interleaved)";

subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-float(4192);
            lives-ok { $buf = $encoder.encode-float(@in-frames) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            lives-ok { $out-fh.write($buf) }, "write that out";
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode floats (interleaved)";
subtest {
    my $sndfile;
    lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

    my $encoder;

    lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

    lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
    lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
    lives-ok { $encoder.bitrate = 320 }, "set bitrate";
    lives-ok { $encoder.quality = 7 }, "set quality";
    lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

    lives-ok { $encoder.init }, "init";

    my $buf;

    my $out-file = $test-data.child("tt.mp3");
    my $out-fh = $out-file.open(:w, :bin);
    loop {
            my @in-frames = $sndfile.read-double(4192);
            lives-ok { $buf = $encoder.encode-double(@in-frames) }, "encode { @in-frames / $sndfile.channels } frames";
            ok($buf ~~ Buf , "returned buffer is a Buf");
            ok($buf.elems > 0, "and there are some elements");
            lives-ok { $out-fh.write($buf) }, "write that out";
            last if ( @in-frames / $sndfile.channels ) != 4192;
    }

    $sndfile.close();


    lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
    ok($buf ~~ Buf , "returned buffer is a Buf");
    ok($buf.elems > 0, "and there are some elements");
    $out-fh.write($buf);
    $out-fh.close;

    if ( "/usr/bin/file".IO.x ) {
        like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
    }

    $out-file.unlink;
}, "encode doubles (interleaved)";

sub uninterleave(@a) {
    my ( $b, $c);
    ($++ %% 2 ?? $b !! $c).push: $_ for @a;
    return $b, $c ;
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
