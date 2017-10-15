#! /usr/bin/env false

use v6.c;

use MPD::Client;
use MPD::Client::Util;

unit module MPD::Client::Status;

#| Clears the current error message in status (this is also accomplished by any
#| command that starts playback).
sub mpd-clearerror (
	IO::Socket::INET $socket,
	--> Bool
) is export {
	mpd-response-ok(mpd-send("clearerror", $socket));
}

#| Displays the song info of the current song (same song that is identified in
#| status).
sub mpd-currentsong (
	IO::Socket::INET $socket,
	--> Hash
) is export {
	mpd-send("currentsong", $socket);
}

#| Waits until there is a noteworthy change in one or more of MPD's subsystems.
#| As soon as there is one, it lists all changed systems in a line in the
#| format changed: SUBSYSTEM, where SUBSYSTEM is one of the following:
#| - database: the song database has been modified after update.
#| - update: a database update has started or finished. If the database was
#|   modified during the update, the database event is also emitted.
#| - stored_playlist: a stored playlist has been modified, renamed, created or
#|   deleted
#| - playlist: the current playlist has been modified
#| - player: the player has been started, stopped or seeked
#| - mixer: the volume has been changed
#| - output: an audio output has been added, removed or modified (e.g. renamed,
#|   enabled or disabled)
#| - options: options like repeat, random, crossfade, replay gain
#| - partition: a partition was added, removed or changed
#| - sticker: the sticker database has been modified.
#| - subscription: a client has subscribed or unsubscribed to a channel
#| - message: a message was received on a channel this client is subscribed to;
#|   this event is only emitted when the queue is empty
#|
#| While a client is waiting for idle results, the server disables timeouts,
#| allowing a client to wait for events as long as mpd runs. The idle command
#| can be canceled by sending the command noidle (no other commands are
#| allowed). MPD will then leave idle mode and print results immediately; might
#| be empty at this time.
#|
#| If the optional SUBSYSTEMS argument is used, MPD will only send notifications
#| when something changed in one of the specified subsytems.
multi sub mpd-idle (
	IO::Socket::INET $socket
	--> Hash
) is export {
	mpd-idle("", $socket);
}

multi sub mpd-idle (
	Str $subsystems,
	IO::Socket::INET $socket
	--> Hash
) is export {
	my $message = "idle";

	if ($subsystems ne "") {
		$message ~= " " ~ $subsystems;
	}

	mpd-send($message, $socket);
}

#| Reports the current status of the player and the volume level.
#| - volume: 0-100
#| - repeat: True or False
#| - random: True or False
#| - single: True or False
#| - consume: True or False
#| - playlist: 31-bit unsigned integer, the playlist version number
#| - playlistlength: integer, the length of the playlist
#| - state: play, stop, or pause
#| - song: playlist song number of the current song stopped on or playing
#| - songid: playlist songid of the current song stopped on or playing
#| - nextsong: playlist song number of the next song to be played
#| - nextsongid: playlist songid of the next song to be played
#| - time: total time elapsed (of current playing/paused song)
#| - elapsed: Total time elapsed within the current song, but with higher
#|   resolution.
#| - duration: Duration of the current song in seconds.
#| - bitrate: instantaneous bitrate in kbps
#| - xfade: crossfade in seconds
#| - mixrampdb: mixramp threshold in dB
#| - mixrampdelay: mixrampdelay in seconds
#| - audio: The format emitted by the decoder plugin during playback, format:
#|   "samplerate:bits:channels". Check the user manual for a detailed
#|   explanation.
#| - updating_db: job id
#| - error: if there is an error, returns message here
multi sub mpd-status (
	IO::Socket::INET $socket
	--> Hash
) is export {
	my @bools = [
		"consume",
		"random",
		"repeat",
		"single",
	];
	my @ints = [
		"duration",
		"mixrampdelay",
		"nextsong",
		"nextsongid",
		"playlist",
		"playlistlength",
		"song",
		"songid",
		"volume",
		"updating_db",
		"xfade",
	];
	my @reals = [
		"mixrampdb",
	];
	my @strings = [
		"error",
		"state",
	];

	$socket
		==> mpd-send("status")
		==> transform-response-bools(@bools)
		==> transform-response-reals(@reals)
		==> transform-response-ints(@ints)
		==> transform-response-strings(@strings)
		;
}

multi sub mpd-status (
	Str $setting,
	IO::Socket::INET $socket
	--> Any
) is export {
	my %response = mpd-status($socket);

	if (!defined(%response{$setting})) {
		return Nil;
	}

	%response{$setting};
}

#| Displays statistics.
#| - artists: number of artists
#| - albums: number of albums
#| - songs: number of songs
#| - uptime: daemon uptime in seconds
#| - db_playtime: sum of all song times in the db
#| - db_update: last db update in UNIX time
#| - playtime: time length of music played
sub mpd-stats (
	IO::Socket::INET $socket
	--> Hash
) is export {
	my @ints = [
		"artists",
		"albums",
		"songs",
		"uptime",
		"db_playtime",
		"db_update",
		"playtime",
	];

	$socket
		==> mpd-send("stats")
		==> transform-response-ints(@ints)
		;
}
