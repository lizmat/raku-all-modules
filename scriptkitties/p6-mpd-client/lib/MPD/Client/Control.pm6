#! /usr/bin/env false

use v6.c;

use MPD::Client::Status;
use MPD::Client::Util;

unit module MPD::Client::Control;

#| Plays next song in the playlist.
sub mpd-next (
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("next", $socket))
}

#| Toggles pause/resumes playing.
multi sub mpd-pause (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-pause(!mpd-status("pause", $socket), $socket)
}

#| Set the pause state to $pause.
multi sub mpd-pause (
	Bool $pause,
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("pause", $pause, $socket))
}

#| Begins playing at the start of the playlist.
multi sub mpd-play (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-send("play", $socket)
}

#| Begins playing the playlist at song number $songpos.
multi sub mpd-play (
	Int $songpos,
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("play", $songpos, $socket))
}

#| Begins playing the playlist at song $songid.
sub mpd-playid (
	Int $songid,
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("playid", $songid, $socket))
}

#| Plays previous song in the playlist.
sub mpd-previous (
	IO::Socket::INET $socket,
	--> Bool
) is export {
	response-is-ok(mpd-send("previous", $socket))
}

#| Seeks to the position $time (in seconds; fractions allowed) of entry
#| $songpos in the playlist.
sub mpd-seek (
	Int $songpos,
	Real $time,
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("seek", [$songpos, $time], $socket))
}

#| Seeks to the position $time (in seconds; fractions allowed) of song $songid.
sub mpd-seekid (
	Int $songid,
	Real $time,
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("seekid", [$songid, $time], $socket))
}

#| Seeks to the position $time (in seconds; fractions allowed) within the
#| current song.
multi sub mpd-seekcur (
	Real $time,
	IO::Socket::INET $socket
	--> Bool
) is export {
	if ($time < 0) {
		MPD::Client::Exceptions::ArgumentException.new("Time must be positive").throw;
	}

	response-is-ok(mpd-send("seekcur", $time, $socket))
}

#| Seeks to the relative position $time (in seconds; fractions allowed) within
#| the current song. The prefix can be either "+" or "-", then the time is
#| relative to the current playing position.
multi sub mpd-seekcur (
	Str $prefix,
	Real $time,
	IO::Socket::INET $socket
	--> Bool
) is export {
	my @prefixes = [
		"+",
		"-",
	];

	if (@prefixes !(cont) $prefix) {
		MPD::Client::Exceptions::ArgumentException.new("Prefix must be one of + or -").throw;
	}

	if ($time < 0) {
		MPD::Client::Exceptions::ArgumentException.new("Time must be positive").throw;
	}

	response-is-ok(mpd-send("seekcur", $prefix ~ $time, $socket))
}

#| Stops playing.
sub mpd-stop (
	IO::Socket::INET $socket
	--> Bool
) is export {
	response-is-ok(mpd-send("stop", $socket))
}

#| Check whether the response from `mpd-send` was an OK status.
sub response-is-ok (
	%response
	--> Bool
) {
	%response eq %()
}
