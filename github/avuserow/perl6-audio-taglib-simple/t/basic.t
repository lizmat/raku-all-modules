use v6;

use Test;
use Audio::Taglib::Simple;

my $tl = Audio::Taglib::Simple.new('t/silence.ogg');

is $tl.file, 't/silence.ogg', 'file';
is $tl.title, '30 Seconds of Silence', 'title';
is $tl.artist, 'avuserow', 'artist';
is $tl.album, 'The Testing Album', 'album';
is $tl.comment, 'Test Comment', 'comment';
is $tl.genre, 'Rock', 'Genre is rock';
is $tl.year, 2014, 'year';
is $tl.track, 30, 'track number';

is $tl.length, 30, 'length';
# XXX: bitrate definition changed at some point in the past, so don't check the
# exact value, just try to run that code
ok $tl.bitrate, 'bitrate';
is $tl.samplerate, 44100, 'sample rate';
is $tl.channels, 1, 'single channel of audio';

$tl.free();

done-testing;
