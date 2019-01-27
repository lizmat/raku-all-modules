#!perl6

use v6;
use Test;

use Audio::Encode::LameMP3;

my @params = 
               { name => "in-samplerate", value => 48000 },
               { name => "num-channels", value => 2 },
               { name => "bitrate", value => 320 },
               { name => "quality", value   =>  2 },
               { name => "mode", value => Audio::Encode::LameMP3::JointStereo },
               { name => "num-samples", value => 2**32 },
               { name => "scale", value => Num(1.0) },
               { name => "scale-left", value => Num(0.5) },
               { name => "scale-right", value   => Num(0) },
               { name => "out-samplerate", value => 44100 },
               { name => "set-analysis", value => False },
               { name => "write-vbr-tag", value => False },
               { name => "decode-only", value => False },
               { name => "nogap-total", value => 0 };

my $obj;

lives-ok { $obj = Audio::Encode::LameMP3.new },"new Audio::Encode::LameMP3";

for @params -> $param {
    can-ok($obj, $param<name>);
    my $val;
    lives-ok { $val = $obj."$param<name>"() }, "can call $param<name>";
    ok($val.defined, "and got some value back");
    lives-ok { $obj."$param<name>"() = $param<value> }, "set $param<name>";
    lives-ok { $val = $obj."$param<name>"() }, "retrieve $param<name> value";
    is($val, $param<value>, "and got back what we set");

}

lives-ok { $obj = Audio::Encode::LameMP3.new(in-samplerate => 22050, bitrate => 192, quality => 5) }, "new with parameters in constructor";

is( $obj.in-samplerate, 22050, "correct samplerate");
is( $obj.bitrate, 192, "correct bitrate");
is( $obj.quality, 5, "correct quality");


done-testing;


# vim: expandtab shiftwidth=4 ft=perl6
