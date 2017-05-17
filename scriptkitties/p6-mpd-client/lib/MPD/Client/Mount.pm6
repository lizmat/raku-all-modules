#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Mount;

sub mpd-mount (
	Str $path,
	Str $uri,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("mount", [$path, $uri], $socket));
}

sub mpd-unmount (
	Str $path,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("unmount", $path, $socket));
}

sub mpd-listmounts (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listmounts", $socket));
}

sub mpd-listneighbours (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listneighbours", $socket));
}
