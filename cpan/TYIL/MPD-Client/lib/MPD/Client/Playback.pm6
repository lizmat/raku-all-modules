#! /usr/bin/env false

use v6.c;

use MPD::Client::Status;
use MPD::Client::Util;
use MPD::Client::Exceptions::ArgumentException;

unit module MPD::Client::Playback;

#| Toggle the consume state. When consume is activated, each song played is
#| removed from playlist.
multi sub mpd-consume (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-consume(!mpd-status("consume", $socket), $socket);
}

#| Sets consume state to $state, which should be True or False. When consume is
#| activated, each song played is removed from playlist.
multi sub mpd-consume (
	Bool $state,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("consume", $state, $socket));
}

#| Disables crossfading between songs.
multi sub mpd-crossfade (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-crossfade(0, $socket);
}

#| Sets crossfading between songs.
multi sub mpd-crossfade (
	Int $seconds,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("crossfade", $seconds, $socket));
}

#| Unsets the threshold at which songs will be overlapped. Like crossfading but
#| doesn't fade the track volume, just overlaps. The songs need to have MixRamp
#| tags added by an external tool. 0dB is the normalized maximum volume so use
#| negative values. In the absence of mixramp tags crossfading will be used.
#| See `http://sourceforge.net/projects/mixramp`.
multi sub mpd-mixrampdb (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-mixrampdb(0, $socket);
}

#| Sets the threshold at which songs will be overlapped. Like crossfading but
#| doesn't fade the track volume, just overlaps. The songs need to have MixRamp
#| tags added by an external tool. 0dB is the normalized maximum volume so use
#| negative values. In the absence of mixramp tags crossfading will be used.
#| See `http://sourceforge.net/projects/mixramp`.
multi sub mpd-mixrampdb (
	Real $decibels,
	IO::Socket::INET $socket
	--> Bool
) is export {
	if ($decibels > 0) {
		MPD::Client::Exceptions::ArgumentException.new("Decibel value must be negative").throw;
	}

	mpd-response-ok(mpd-send("mixrampdb", $decibels, $socket));
}

#| Removes the mixramp delay, making it fall back to crossfading.
multi sub mpd-mixrampdelay (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-mixrampdelay(0, $socket);
}

#| Additional time subtracted from the overlap calculated by mixrampdb.
multi sub mpd-mixrampdelay (
	Int $seconds,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("mixrampdelay", $seconds, $socket));
}

#| Toggle the random state.
multi sub mpd-random (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-random(!mpd-status("random", $socket), $socket);
}

#| Sets random state to $state, which should be True or False.
multi sub mpd-random (
	Bool $state,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("random", $state, $socket));
}

#| Toggle the repeat state.
multi sub mpd-repeat (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-repeat(!mpd-status("repeat", $socket), $socket);
}

#| Sets repeat state to $state, which should be True or False.
multi sub mpd-repeat (
	Bool $state,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("repeat", $state, $socket));
}

#| Sets volume to $volume, the range of volume is 0-100. If you want to change
#| the volume relatively, use `mpd-volume`.
sub mpd-setvol (
	Int $volume,
	IO::Socket::INET $socket
	--> Bool
) is export {
	if ($volume < 0) {
		MPD::Client::Exceptions::ArgumentException.new("Volume must be positive").throw;
	}

	if ($volume > 100) {
		MPD::Client::Exceptions::ArgumentException.new("Volume cannot exceed 100").throw;
	}

	mpd-response-ok(mpd-send("setvol", $volume, $socket));
}

#| Toggle single state. When single is activated, playback is stopped after
#| current song, or song is repeated if the 'repeat' mode is enabled.
multi sub mpd-single (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-single(!mpd-status("single", $socket), $socket);
}

#| Sets single state to $state, which should be True or False. When single is
#| activated, playback is stopped after current song, or song is repeated if
#| the 'repeat' mode is enabled.
multi sub mpd-single (
	Bool $state,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("single", $state, $socket));
}

#| Sets the replay gain mode. One of "off", "track", "album", "auto". Changing
#| the mode during playback may take several seconds, because the new settings
#| does not affect the buffered data. This command triggers the options idle
#| event.
sub mpd-replay-gain-mode (
	Str $mode,
	IO::Socket::INET $socket
	--> Bool
) is export {
	my $acceptables = set <
		album
		auto
		off
		track
	>;

	if (!$acceptables{$mode}) {
		MPD::Client::Exceptions::ArgumentException.new("Mode '$mode' is illegal for replay_gain_mode").throw;
	}

	mpd-response-ok(mpd-send("replay_gain_mode", $mode, $socket));
}

#| Retrieve replay gain options. Currently, only the variable replay_gain_mode
#| is returned.
multi sub mpd-replay-gain-status (
	IO::Socket::INET $socket
	--> Hash
) is export {
	$socket
		==> mpd-send-raw("replay_gain_status")
		==> mpd-response()
		==> transform-response-strings(["replay_gain_mode"])
		;
}

#| Retrieve a single given replay gain option.
multi sub mpd-replay-gain-status (
	Str $key,
	IO::Socket::INET $socket
	--> Any
) is export {
	mpd-replay-gain-status($socket){$key};
}

#| Changes volume by amount $change.
sub mpd-volume (
	Int $change,
	IO::Socket::INET $socket
	--> Bool
) is export {
	my $current = mpd-status("volume", $socket);
	my $new = $current + $change;

	mpd-setvol($new, $socket);
}
