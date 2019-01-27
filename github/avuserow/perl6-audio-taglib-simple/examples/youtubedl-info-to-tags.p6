#!/usr/bin/env perl6

use v6;

use Audio::Taglib::Simple;
use JSON::Tiny;

#| Tool to copy metadata output from `youtube-dl --write-info-json` into
#| resulting audio files.
sub MAIN(IO() $audio-file) {
	my $json-file = $audio-file.extension('info.json');
	say "copying metadata from $json-file for $audio-file";

	my $info = from-json($json-file.slurp);
	my $tags = Audio::Taglib::Simple.new($audio-file);
	$tags.album = $info<album>;
	$tags.artist = $info<artist>;
	$tags.track = $info<track_number>;
	$info<release_date> ~~ /(\d ** 4)/;
	my $year = +$0;
	$tags.year = $year;
	$tags.comment = "$info<webpage_url>\n$info<id>";
	$tags.save;
}
