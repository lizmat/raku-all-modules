use v6;
use lib "lib";
use Test;

use Audio::Sndfile;

my $f;

diag "Testing with " ~ Audio::Sndfile.library-version;

my $empty-file = 't/data/empty_16le_48000_2ch.wav';

throws-like { $f = Audio::Sndfile.new() }, "Required named parameter 'filename' not passed", "constructor no args";

throws-like { $f = Audio::Sndfile.new(filename => $empty-file) }, "exactly one of ':r', ':w', ':rw' must be provided", "constructor no mode";

throws-like { $f = Audio::Sndfile.new(filename => $empty-file, :r, :rw) }, "exactly one of ':r', ':w', ':rw' must be provided", "constructor multiple modes";

lives-ok { $f = Audio::Sndfile.new(filename => $empty-file, :r) }, "constructor with sensible arguments";

isa-ok($f, Audio::Sndfile);
is($f.mode, Audio::Sndfile::OpenMode::Read, "and it has Read");

ok($f.info.format-check, "the library filled in the info so it should be good");
is($f.info.channels,2, "got the expected number of channels");
is($f.info.samplerate, 48000, "got the expected samplerate");
is($f.info.format, 65538, "And it is a WAV PCM 16LE (Raw number)");
is($f.info.type, Audio::Sndfile::Info::Format::WAV, "It's a WAV");
is($f.info.sub-type, Audio::Sndfile::Info::Subformat::PCM_16, "It's a PCM 16");
isa-ok($f.info.duration, Duration, "duration returns a Duration object");
is($f.info.duration, 0, "and because it is empty duration is 0");
lives-ok { $f.close() }, "close";

lives-ok { $f = Audio::Sndfile.new(filename => 't/data/1second_16le_48000_2ch.wav', :r) }, "open another file";

is-approx($f.info.duration,1.002667,"and this file has a duration of approximately 1 second (it's actually 48124 frames long)");

# just a drive by here. If I've got it wrong this may completely kill moar
is($f.read-short(10).elems, 20, "managed to read ten frames with read-short");
is($f.read-int(10).elems, 20, "managed to read ten frames with read-int");
is($f.read-float(10).elems, 20, "managed to read ten frames with read-float");
is($f.read-double(10).elems, 20, "managed to read ten frames with read-double");

lives-ok { $f.close() }, "close";

throws-like { $f = Audio::Sndfile.new(filename => "bogus-test-file.wav", :r) },"System error : No such file or directory.", "constructor with bogus filename";



done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
