#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Partition;

#| Switch the client to a different partition.
sub mpd-partition (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("partition", $name, $socket));
}

#| Get an array of partitions.
sub mpd-listpartitions (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listpartitions", $socket));
}

#| Create a new partition.
sub mpd-newpartition (
	Str $name,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("newpartition", $name, $socket));
}
