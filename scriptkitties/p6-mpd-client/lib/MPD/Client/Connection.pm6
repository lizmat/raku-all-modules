#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Sticker;

sub mpd-close (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-send("close", $socket);

	True;
}

sub mpd-kill (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("kill", $socket));
}

sub mpd-password (
	Str $password,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("password", $password, $socket));
}

sub mpd-ping (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("ping", $socket));
}

sub mpd-tagtypes (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("tagtypes", $socket));
}

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

sub mpd-tagtypes-clear (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes clear", $socket));
}

sub mpd-tagtypes-all (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("tagtypes all", $socket));
}
