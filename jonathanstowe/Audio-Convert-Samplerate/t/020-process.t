#!perl6

use v6;
use lib 'lib';
use Test;

use Audio::Convert::Samplerate;
use Audio::Sndfile;
use NativeCall;

my $test-data = $*CWD.child('t/data');

my $test-file-in    = $test-data.child('1sec-chirp-22050.wav');
my $test-file-out   = $test-data.child("test-out-{ $*PID }.wav");

{
    my Audio::Sndfile $in-obj;

    lives-ok { $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r) }, "open test file for reading";

    my Audio::Convert::Samplerate $conv-obj;

    lives-ok { $conv-obj = Audio::Convert::Samplerate.new(channels => $in-obj.channels) }, "create a new Audio::Convert::Samplerate";

    my $bufsize = 1024;

    my $in-frames-total = 0;
    my $out-frames-total = 0;

    loop {
        my ($in-frames, $num-frames) = $in-obj.read-float($bufsize, :raw).list;
        $in-frames-total += $num-frames;
        my $buf;
        my Bool $last = ($num-frames != $bufsize);
        lives-ok { $buf = $conv-obj.process($in-frames, $num-frames, 2, $last) }, "process $num-frames frames";
        $out-frames-total += $buf[1];
        isa-ok $buf[0], CArray[num32], "got the right sort of array back";
        last if $last;
    }
    ok( ($out-frames-total / ($in-frames-total * 2)) < 1, "got the expected total number of frames (approximately)");
}
{
    my Audio::Sndfile $in-obj;

    lives-ok { $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r) }, "open test file for reading";

    my Audio::Convert::Samplerate $conv-obj;

    lives-ok { $conv-obj = Audio::Convert::Samplerate.new(channels => $in-obj.channels) }, "create a new Audio::Convert::Samplerate";

    my $bufsize = 1024;

    my $in-frames-total = 0;
    my $out-frames-total = 0;

    loop {
        my ($in-frames, $num-frames) = $in-obj.read-short($bufsize, :raw).list;
        $in-frames-total += $num-frames;
        my $buf;
        my Bool $last = ($num-frames != $bufsize);
        lives-ok { $buf = $conv-obj.process($in-frames, $num-frames, 2, $last) }, "process $num-frames frames";
        $out-frames-total += $buf[1];
        isa-ok $buf[0], CArray[int16], "got the right sort of array back";
        last if $last;
    }
    ok( ($out-frames-total / ($in-frames-total * 2)) < 1, "got the expected total number of frames (approximately)");
}
{
    my Audio::Sndfile $in-obj;

    lives-ok { $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r) }, "open test file for reading";

    my Audio::Convert::Samplerate $conv-obj;

    lives-ok { $conv-obj = Audio::Convert::Samplerate.new(channels => $in-obj.channels) }, "create a new Audio::Convert::Samplerate";

    my $bufsize = 1024;

    my $in-frames-total = 0;
    my $out-frames-total = 0;

    loop {
        my ($in-frames, $num-frames) = $in-obj.read-int($bufsize, :raw).list;
        $in-frames-total += $num-frames;
        my $buf;
        my Bool $last = ($num-frames != $bufsize);
        lives-ok { $buf = $conv-obj.process($in-frames, $num-frames, 2, $last) }, "process $num-frames frames";
        $out-frames-total += $buf[1];
        isa-ok $buf[0], CArray[int32], "got the right sort of array back";
        last if $last;
    }
    ok(($out-frames-total / ($in-frames-total * 2)) < 1, "got the expected total number of frames (approximately)");
}
{
    my Audio::Sndfile $in-obj;

    lives-ok { $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r) }, "open test file for reading";

    my Audio::Convert::Samplerate $conv-obj;

    lives-ok { $conv-obj = Audio::Convert::Samplerate.new(channels => $in-obj.channels) }, "create a new Audio::Convert::Samplerate";

    my $bufsize = 1024;

    my $in-frames-total = 0;
    my $out-frames-total = 0;

    loop {
        my @data = $in-obj.read-float($bufsize);
        $in-frames-total += @data.elems;
        my Bool $last = (@data.elems != ($bufsize * $in-obj.channels));

        my @buf;
        todo("Bug with CArray[num32] : https://rt.perl.org/Ticket/Display.html?id=125408", 1);
        lives-ok { @buf = $conv-obj.process-float(@data, 2, $last) }, "process { @data.elems / $in-obj.channels } frames (floats as an array)";
        $out-frames-total += @buf.elems;
        last if $last;
    }
    ok( ($out-frames-total / ($in-frames-total * 2)) < 1, "got the expected total number of frames (approximately)");
}
{
    my Audio::Sndfile $in-obj;

    lives-ok { $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r) }, "open test file for reading";

    my Audio::Convert::Samplerate $conv-obj;

    lives-ok { $conv-obj = Audio::Convert::Samplerate.new(channels => $in-obj.channels) }, "create a new Audio::Convert::Samplerate";

    my $bufsize = 1024;

    my $in-frames-total = 0;
    my $out-frames-total = 0;

    loop {
        my @data = $in-obj.read-short($bufsize);
        $in-frames-total += @data.elems;
        my Bool $last = (@data.elems != ($bufsize * $in-obj.channels));

        my @buf;
        lives-ok { @buf = $conv-obj.process-short(@data, 2, $last) }, "process { @data.elems / $in-obj.channels } frames (shorts as an array)";
        $out-frames-total += @buf.elems;
        last if $last;
    }
    ok( ($out-frames-total / ($in-frames-total * 2)) < 1, "got the expected total number of frames (approximately)");
}
{
    my Audio::Sndfile $in-obj;

    lives-ok { $in-obj = Audio::Sndfile.new(filename => $test-file-in, :r) }, "open test file for reading";

    my Audio::Convert::Samplerate $conv-obj;

    lives-ok { $conv-obj = Audio::Convert::Samplerate.new(channels => $in-obj.channels) }, "create a new Audio::Convert::Samplerate";

    my $bufsize = 1024;

    my $in-frames-total = 0;
    my $out-frames-total = 0;

    loop {
        my @data = $in-obj.read-int($bufsize);
        $in-frames-total += @data.elems;
        my Bool $last = (@data.elems != ($bufsize * $in-obj.channels));

        my @buf;
        lives-ok { @buf = $conv-obj.process-int(@data, 2, $last) }, "process { @data.elems / $in-obj.channels } frames (ints as an array)";
        $out-frames-total += @buf.elems;
        last if $last;
    }
    ok( ($out-frames-total / ($in-frames-total * 2)) < 1, "got the expected total number of frames (approximately)");
}



done;
# vim: expandtab shiftwidth=4 ft=perl6
