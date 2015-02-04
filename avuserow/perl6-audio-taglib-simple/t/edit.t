use v6;

use Test;
use Audio::Taglib::Simple;

# copy the example file
IO::Path.new('t/silence.ogg').copy('t/modified.ogg');

my $tl = Audio::Taglib::Simple.new('t/modified.ogg');
is $tl.length, 30, 'sanity check: length after copy';

my %edits = (
	title => 'new title',
	artist => 'new artist',
	album => 'new album',
	comment => "new comment, time is { now }",
	genre => 'Other',
	year => 1999,
	track => 244,
);

for %edits.kv -> $key, $val {
	$tl."$key"() = $val;
	is $tl."$key"(), $val, "$key was updated in memory";
}

ok $tl.save(), 'file saved';

# check the edits
$tl = Audio::Taglib::Simple.new('t/modified.ogg');
for %edits.kv -> $key, $val {
	is $tl."$key"(), $val, "$key was updated on disk";
}

$tl.free();

done;
