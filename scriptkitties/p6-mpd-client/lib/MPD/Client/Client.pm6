#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Client;

#| Subscribe to a channel. The channel is created if it does not exist already.
#| The name may consist of alphanumeric ASCII characters plus underscore, dash,
#| dot and colon.
sub mpd-subscribe (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("subscribe", $socket));
}

#| Unsubscribe from a channel.
sub mpd-unsubscribe (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("unsubscribe", $socket));
}

#| Obtain an array of all channels.
sub mpd-channels (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("channels", $socket));
}

#| Returns messages for this client.
sub mpd-readmessages (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("readmessages", $socket));
}

#| Send a message to the specified channel.
sub mpd-sendmessage (
	Str $channel,
	Str $text,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("sendmessage", [$channel, $text], $socket));
}
