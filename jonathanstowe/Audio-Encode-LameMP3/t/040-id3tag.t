#!perl6

use v6;
use lib 'lib';
use Test;

use Audio::Encode::LameMP3;
use Audio::Taglib::Simple;



my IO::Path $test-data = "t/data".IO;

my $encoder;

lives-ok { $encoder = Audio::Encode::LameMP3.new(in-samplerate => 44100, mode => Audio::Encode::LameMP3::JointStereo, bitrate => 128, quality => 9) }, "create an encoder";

lives-ok { $encoder.title = "Test Title" }, "set a title";
lives-ok { $encoder.artist = "Test Artist" }, "set artist";
lives-ok { $encoder.album = "Test Album" }, "set album";
lives-ok { $encoder.year = "2015" }, "set year";
lives-ok { $encoder.comment = "Test Comment" }, "set a comment";

my $buf;

my $out-file = $test-data.child("tt-id3.mp3");
my $out-fh = $out-file.open(:w, :bin);
my @in-frames = (0) xx 4192;

lives-ok { $buf = $encoder.encode-short(@in-frames) }, "encode { @in-frames / 2 } frames";
ok($buf ~~ Buf , "returned buffer is a Buf");
ok($buf.elems > 0, "and there are some elements");
$out-fh.write($buf);


lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
ok($buf ~~ Buf , "returned buffer is a Buf");
ok($buf.elems > 0, "and there are some elements");
$out-fh.write($buf);
$out-fh.close;

my $taglib;

lives-ok { $taglib = Audio::Taglib::Simple.new($out-file.Str) }, "get a taglib object";
is($taglib.title, "Test Title", "got title we expected");
is($taglib.artist, "Test Artist", "got artist we expected");
is($taglib.album, "Test Album", "got album we expected");
is($taglib.year, "2015", "got year we expected");
is($taglib.comment, "Test Comment", "got the comment we expected");


$out-file.unlink;

done;
# vim: expandtab shiftwidth=4 ft=perl6
