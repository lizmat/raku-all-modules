#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Reflection;

#| Dumps configuration values that may be interesting for the client.
#| This command is only permitted to "local" clients (connected via UNIX
#| domain socket).
# TODO: Either allow UNIX sockets, or drop this command
sub mpd-config (
	IO::Socket::INET $socket
	--> Hash
) is export {
	mpd-send("config", $socket);
}

#| Get an array of which commands the current user has access to.
sub mpd-commands (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("commands", $socket));
}

#| Get an array of commands the current user does not have access to.
sub mpd-notcommands (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("notcommands", $socket));
}

#| Gets a list of available URL handlers.
sub mpd-urlhandlers (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("urlhandlers", $socket));
}

#| Get an array of decoder plugins, including their supported suffixes and
#| MIME types.
sub mpd-decoders (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("decoders", $socket));
}
