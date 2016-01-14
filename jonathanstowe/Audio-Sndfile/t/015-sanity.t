#!perl6

use v6;
use Test;
use Shell::Command;

use NativeCall;
use lib 'lib';

use Audio::Sndfile;

my $test-output = "t/test-output".IO;

$test-output.mkdir unless $test-output.d;

my $rc;

my @shorts = [0, 0, 309, 309, 896, 896, 1666, 1666, 1847, 1847, 1229, 1229, 681, 681, 920, 920, 744, 744, -877, -877, -3842, -3842, -5170, -5170, -4448, -4448, -4761, -4761, -5750, -5750, -5910, -5910, -6393, -6393, -9136, -9136, -11962, -11962, -15651, -15651, -18509, -18509, -18499, -18499, -17179, -17179, -15175, -15175, -13946, -13946]<>;

my $short-path = $test-output.child("short-noise-sanity.way");
my $short-obj-out;
lives-ok { $short-obj-out = Audio::Sndfile.new(filename => $short-path,  samplerate => 44100, channels => 2, format => 65538, :w) }, "open shorts for writing";
lives-ok { $rc = $short-obj-out.write-short(@shorts) }, "write-shorts";
is($rc, 25, "managed to write 25");
lives-ok { $short-obj-out.close() }, "close that";
my $short-obj-in;
lives-ok { $short-obj-in =  Audio::Sndfile.new(filename => $short-path, :r) }, "open that file for reading";
is($short-obj-in.frames, 25, "got the right number of frames");
is($short-obj-in.format, 65538, "got the right format");
my @shorts-in;
lives-ok { @shorts-in = $short-obj-in.read-short(25) }, "read 25 frames back";
ok(@shorts-in ~~ @shorts, "and it is the same data");
lives-ok { $short-obj-in.close }, "close that";

my $shorts-carray = CArray[int16].new;

$shorts-carray[$_] = @shorts[$_] for ^50;

my $short-raw-path = $test-output.child("short-raw-noise-sanity.way");
my $short-raw-obj-out;
lives-ok { $short-raw-obj-out = Audio::Sndfile.new(filename => $short-raw-path,  samplerate => 44100, channels => 2, format => 65538, :w) }, "open shorts for writing";
lives-ok { $rc = $short-raw-obj-out.write-short($shorts-carray, 25) }, "write-shorts";
is($rc, 25, "managed to write 25");
lives-ok { $short-raw-obj-out.close() }, "close that";
my $short-raw-obj-in;
lives-ok { $short-raw-obj-in =  Audio::Sndfile.new(filename => $short-raw-path, :r) }, "open that file for reading";
is($short-raw-obj-in.frames, 25, "got the right number of frames");
is($short-raw-obj-in.format, 65538, "got the right format");
my ($shorts-raw-in,$shorts-raw-frames);
lives-ok { ($shorts-raw-in, $shorts-raw-frames) = $short-raw-obj-in.read-short(25, :raw).list }, "read 25 frames back";
isa-ok($shorts-raw-in, CArray[int16], "got back a CArray");
is($shorts-raw-frames,25,"got the right number of frames back");
#ok(@shorts-in ~~ @shorts, "and it is the same data");
lives-ok { $short-raw-obj-in.close }, "close that";



my @ints = [-839974912, -839974912, -732561408, -732561408, -667549696, -667549696, -591986688, -591986688, -712769536, -712769536, -649265152, -649265152, -646643712, -646643712, -688586752, -688586752, -685768704, -685768704, -764084224, -764084224, -668467200, -668467200, -403636224, -403636224, -22151168, -22151168, 93454336, 93454336, 383320064, 383254528, 911474688, 911409152, 1454112768, 1454112768, 1692598272, 1692598272, 1791557632, 1791557632, 1821114368, 1821114368, 2123235328, 2123235328, 2032140288, 2032140288, 1670840320, 1670840320, 1482883072, 1482883072, 1171324928, 1171324928]<>;

my $int-path = $test-output.child("int-noise-sanity.way");
my $int-obj-out;
lives-ok { $int-obj-out = Audio::Sndfile.new(filename => $int-path,  samplerate => 44100, channels => 2, format => 65538, :w) }, "open ints for writing";
lives-ok { $rc = $int-obj-out.write-int(@ints) }, "write-ints";
is($rc, 25, "managed to write 25");
lives-ok { $int-obj-out.close() }, "close that";
my $int-obj-in;
lives-ok { $int-obj-in =  Audio::Sndfile.new(filename => $int-path, :r) }, "open that file for reading";
is($int-obj-in.frames, 25, "got the right number of frames");
is($int-obj-in.format, 65538, "got the right format");
my @ints-in;
lives-ok { @ints-in = $int-obj-in.read-int(25) }, "read 25 frames back";
ok(@ints-in ~~ @ints, "and it is the same data");
lives-ok { $int-obj-in.close }, "close that";

my @floats = [0.4971923828125e0, 0.4971923828125e0, 0.458831787109375e0, 0.458831787109375e0, 0.475372314453125e0, 0.475372314453125e0, 0.453094482421875e0, 0.453094482421875e0, 0.47576904296875e0, 0.47576904296875e0, 0.46405029296875e0, 0.46405029296875e0, 0.5028076171875e0, 0.5028076171875e0, 0.437469482421875e0, 0.437469482421875e0, 0.250091552734375e0, 0.250091552734375e0, 0.11273193359375e0, 0.11273193359375e0, -0.0933837890625e0, -0.0933837890625e0, -0.322845458984375e0, -0.322845458984375e0, -0.52227783203125e0, -0.522308349609375e0, -0.52490234375e0, -0.52490234375e0, -0.477142333984375e0, -0.477142333984375e0, -0.463409423828125e0, -0.463409423828125e0, -0.2515869140625e0, -0.2515869140625e0, -0.13873291015625e0, -0.13873291015625e0, -0.205474853515625e0, -0.205474853515625e0, -0.1044921875e0, -0.1044921875e0, -0.233856201171875e0, -0.233856201171875e0, -0.236114501953125e0, -0.236114501953125e0, -0.0379638671875e0, -0.0379638671875e0, -0.0302734375e0, -0.0302734375e0, 0.071441650390625e0, 0.071441650390625e0]<>;

my $float-path = $test-output.child("float-noise-sanity.way");
my $float-obj-out;
lives-ok { $float-obj-out = Audio::Sndfile.new(filename => $float-path,  samplerate => 44100, channels => 2, format => 65542, :w) }, "open floats for writing";
lives-ok { $rc = $float-obj-out.write-float(@floats) }, "write-floats";
is($rc, 25, "managed to write 25");
lives-ok { $float-obj-out.close() }, "close that";
my $float-obj-in;
lives-ok { $float-obj-in =  Audio::Sndfile.new(filename => $float-path, :r) }, "open that file for reading";
is($float-obj-in.frames, 25, "got the right number of frames");
is($float-obj-in.format, 65542, "got the right format");
my @floats-in;
lives-ok { @floats-in = $float-obj-in.read-float(25) }, "read 25 frames back";
ok(@floats-in ~~ @floats, "and it is the same data");

# just to get better diagnostics if it doesn't work
sub compare-arrays(@arr1, @arr2) {
    if @arr1.elems != @arr2.elems {
        diag "lengths differ";
    }
    else {
        for ^@arr1.elems -> $i {
            if @arr1[$i] != @arr2[$i] {
                diag "Arrays differ at $i { @arr1[$i] } vs { @arr2[$i] }";
            }
        }
    }
}

compare-arrays(@floats-in, @floats);
lives-ok { $float-obj-in.close }, "close that";

my @doubles = [0.1514892578125e0, 0.1514892578125e0, 0.030181884765625e0, 0.030181884765625e0, -0.115936279296875e0, -0.115936279296875e0, -0.355926513671875e0, -0.35589599609375e0, -0.317901611328125e0, -0.31787109375e0, -0.4263916015625e0, -0.4263916015625e0, -0.706207275390625e0, -0.706207275390625e0, -0.3299560546875e0, -0.3299560546875e0, -0.195556640625e0, -0.195556640625e0, -0.37835693359375e0, -0.37835693359375e0, -0.10394287109375e0, -0.10394287109375e0, 0.114715576171875e0, 0.114715576171875e0, 0.228607177734375e0, 0.228607177734375e0, 0.422821044921875e0, 0.422821044921875e0, 0.401885986328125e0, 0.401885986328125e0, 0.313629150390625e0, 0.313629150390625e0, 0.20245361328125e0, 0.20245361328125e0, 0.125396728515625e0, 0.125396728515625e0, 0.184295654296875e0, 0.184295654296875e0, 0.116241455078125e0, 0.116241455078125e0, 0.095611572265625e0, 0.095611572265625e0, -0.05169677734375e0, -0.05169677734375e0, -0.079833984375e0, -0.079833984375e0, 0.117523193359375e0, 0.117523193359375e0, 0.19610595703125e0, 0.19610595703125e0]<>;

my $double-path = $test-output.child("double-noise-sanity.way");
my $double-obj-out;
lives-ok { $double-obj-out = Audio::Sndfile.new(filename => $double-path,  samplerate => 44100, channels => 2, format => 65543, :w) }, "open doubles for writing";
lives-ok { $rc = $double-obj-out.write-double(@doubles) }, "write-doubles";
is($rc, 25, "managed to write 25");
lives-ok { $double-obj-out.close() }, "close that";
my $double-obj-in;
lives-ok { $double-obj-in =  Audio::Sndfile.new(filename => $double-path, :r) }, "open that file for reading";
is($double-obj-in.frames, 25, "got the right number of frames");
is($double-obj-in.format, 65543, "got the right format");
my @doubles-in;
lives-ok { @doubles-in = $double-obj-in.read-double(25) }, "read 25 frames back";
ok(@doubles-in ~~ @doubles, "and it is the same data");
compare-arrays(@doubles-in, @doubles);
lives-ok { $double-obj-in.close }, "close that";

done-testing;

END {
       rm_rf $test-output.Str;
}

# vim: expandtab shiftwidth=4 ft=perl6
