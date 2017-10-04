#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Playlist;

sub mpd-listplaylist (
	Str $name,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-send-raw("listplaylist $name", $socket);

	my @playlist;

	for $socket.get() -> $line {
		if ($line eq "OK") {
			last;
		}

		if (my $match = MPD::Client::Grammars::PlaylistLine.parse($line)) {
			@playlist.push($match<path>);
		}
	}

	@playlist;
}

sub mpd-listplaylistinfo (
	Str $name,
	IO::Socket::INET $socket
	--> Array
) is export {
	my @hits;
	my $index = -1;

	for $socket.get() -> $line {
		if ($line eq "OK") {
			last;
		}

		if (my $match = MPD::Client::Grammars::ResponseLine.parse($line)) {
			if ($match<key> eq "file") {
				@hits[++$index] = {};
			}

			@hits[$index]{$match<key>} = $match<value>;
		}
	}

	@hits;
}

sub mpd-listplaylists (
	IO::Socket::INET $socket
	--> Array
) is export {
	my @hits;
	my $index = -1;

	for $socket.get() -> $line {
		if ($line eq "OK") {
			last;
		}

		if (my $match = MPD::Client::Grammars::ResponseLine.parse($line)) {
			if ($match<key> eq "playlist") {
				@hits[++$index] = {};
			}

			@hits[$index]{$match<key>} = $match<value>;
		}
	}

	@hits;
}

multi sub mpd-load (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("load", $name, $socket));
}

multi sub mpd-load (
	Str $name,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("load", [$name, "$start:$end"], $socket));
}

sub mpd-playlistadd (
	Str $name,
	Str $uri,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("playlistadd", [$name, $uri], $socket));
}

sub mpd-playlistclear (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("playlistclear", $name, $socket));
}

sub mpd-playlistdelete (
	Str $name,
	Int $songpos,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("playlistdelete", [$name, $songpos], $socket));
}

sub mpd-playlistmove (
	Str $name,
	Int $from,
	Int $to,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("playlistmove", [$name, $from, $to], $socket));
}

sub mpd-rename (
	Str $name,
	Str $new-name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("rename", [$name, $new-name], $socket));
}

sub mpd-rm (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("rm", $name, $socket));
}

sub mpd-save (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("save", $name, $socket));
}
