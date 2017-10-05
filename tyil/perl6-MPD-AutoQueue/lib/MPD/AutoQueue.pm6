#! /usr/bin/env false

use v6.c;

unit module MPD::AutoQueue;

use MPD::Client::Current;
use MPD::Client::Database;
use MPD::Client::Control;

sub pick-file
(
	:@database
	--> Str
) is export {
	my $pick;

	loop {
		$pick = @database.pick;

		last if $pick<type> eq "file";
	}

	$pick<path>.Str;
}

sub queue-random
(
	:$client,
	:@database,
	Bool :$say = False
	--> Str
) is export {
	my @playlist = mpd-playlistinfo($client);

	if (0 < @playlist.elems) {
		return "";
	}

	my $pick;

	loop {
		$pick = pick-file(:@database);

		last if mpd-add($pick, $client);
	}

	mpd-play($client);

	if ($say) {
		say "Queued $pick";
	}

	$pick;
}

sub update-database
(
	:$client,
	Bool :$say = False
) is export {
	my @results = mpd-listall($client);

	if ($say) {
		say "Database contains {@results.elems} entries";
	}

	@results;
}
