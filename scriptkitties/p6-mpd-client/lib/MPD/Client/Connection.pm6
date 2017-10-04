#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Sticker;

#| Closes the connection to MPD. MPD will try to send the remaining output
#| buffer before it actually closes the connection, but that cannot be
#| guaranteed. This command will not generate a response from MPD.
sub mpd-close (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-send("close", $socket);

	True;
}

#| Kills MPD.
sub mpd-kill (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("kill", $socket));
}

#| This is used for authentication with the server. PASSWORD is simply the
#| plaintext password.
sub mpd-password (
	Str $password,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("password", $password, $socket));
}

#| Does nothing but return True.
sub mpd-ping (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("ping", $socket));
}

#| Shows a list of available tag types. It is an intersection of the
#| metadata_to_use setting and this client's tag mask. About the tag mask: each
#| client can decide to disable any number of tag types, which will be omitted
#| from responses to this client. That is a good idea, because it makes
#| responses smaller.
sub mpd-tagtypes (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("tagtypes", $socket));
}

#| Re-enable one or more tags from the list of tag types for this client. These
#| will no longer be hidden from responses to this client.
multi sub mpd-tagtypes-enable (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes enable", $name, $socket));
}

multi sub mpd-tagtypes-enable (
	Array @names,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes enable", @names, $socket));
}

#| Remove one or more tags from the list of tag types the client is interested
#| in. These will be omitted from responses to this client.
multi sub mpd-tagtypes-disable (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes disable", $name, $socket));
}

multi sub mpd-tagtypes-disable (
	Array @names,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes disable", @names, $socket));
}

#| Clear the list of tag types this client is interested in. This means that
#| MPD will not send any tags to this client.
sub mpd-tagtypes-clear (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes clear", $socket));
}

#| Announce that this client is interested in all tag types. This is the
#| default setting for new clients. 
sub mpd-tagtypes-all (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes all", $socket));
}
