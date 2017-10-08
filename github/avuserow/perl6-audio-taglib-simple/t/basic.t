use v6;

use Test;
use Audio::Taglib::Simple;

plan 12;

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
is $tl.bitrate, 96, 'bitrate';
is $tl.samplerate, 44100, 'sample rate';
is $tl.channels, 1, 'single channel of audio';

$tl.free();
