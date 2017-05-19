#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Output;

#| Turns an output off.
sub mpd-disableoutput (
	Int $id,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("disableoutput", $id, $socket));
}

#| Turns an output on.
sub mpd-enableoutput (
	Int $id,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("enableoutput", $id, $socket));
}

#| Turns an output on or off, depending on the current state.
sub mpd-toggleoutput (
	Int $id,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("toggleoutput", $id, $socket));
}

#| Shows information about all outputs.
sub mpd-outputs (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("outputs", $socket));
}
