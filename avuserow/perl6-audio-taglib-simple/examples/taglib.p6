#!/usr/bin/env perl6

use v6;

use Audio::Taglib::Simple;

multi MAIN() {
	say "Provide one or more audio files as arguments.";
	exit 1;
}

multi MAIN(*@files) {
	my $music = 0;
	my $non-music = 0;
	for @files -> $file {
		try {
			CATCH {
				say "$file was not a recognized audio format.";
				$non-music++;
				next;
			}
			my $tl = Audio::Taglib::Simple.new($file);
			say $tl.file;

			for <title artist album comment genre year track length bitrate samplerate channels> {
				say "$_: ", $tl."$_"();
			}
			$music++;
			$tl.free();
		}
		say '';
	}

	say "Took ", (now - BEGIN now), " seconds";
	say "Found $music music files, $non-music non-music.";
}
