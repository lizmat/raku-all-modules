#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Sticker;

# TODO: Give the right response, local mpd is compiled without stickers
sub mpd-sticker-get (
	Str $type,
	Str $uri,
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("sticker get", [$type, $uri, $name], $socket));
}

sub mpd-sticker-set (
	Str $type,
	Str $uri,
	Str $name,
	Str $value,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("sticker set", [$type, $uri, $name, $value], $socket));
}

sub mpd-sticker-delete (
	Str $type,
	Str $uri,
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("sticker delete", [$type, $uri, $name], $socket));
}

sub mpd-sticker-list (
	Str $type,
	Str $uri,
	IO::Socket::INET $socket
	--> Hash
) is export {
	mpd-send("sticker list", [$type, $uri], $socket);
}

multi sub mpd-sticker-find (
	Str $type,
	Str $uri,
	Str $name,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("sticker find $type $uri $name", $socket));
}

multi sub mpd-sticker-find (
	Str $type,
	Str $uri,
	Str $name,
	Str $value,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("sticker find $type $uri $name = $value", $socket));
}
