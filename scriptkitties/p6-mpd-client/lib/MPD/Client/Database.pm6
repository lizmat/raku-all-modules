#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Database;

multi sub mpd-count (
	Str $tag,
	Str $needle,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("count $tag $needle", $socket));
}

multi sub mpd-count (
	Str $tag,
	Str $needle,
	Str $grouptype,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("count $tag $needle group $grouptype", $socket));
}

multi sub mpd-find (
	Str $type,
	Str $what,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("find $type $what", $socket));
}

multi sub mpd-find (
	Str $type,
	Str $what,
	Str $sort-type,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("find $type $what sort $sort-type", $socket));
}

multi sub mpd-find (
	Str $type,
	Str $what,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("find $type $what window $start:$end", $socket));
}

multi sub mpd-find (
	Str $type,
	Str $what,
	Str $sort-type,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("find $type $what sort $sort-type window $start:$end", $socket));
}

sub mpd-findadd (
	Str $type,
	Str $what,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("findadd", [$type, $what], $socket));
}

# TODO: Come up with a sane way to deal with all variants of this one
multi sub mpd-list (
	Str $type,
	IO::Socket::INET $socket
) is export {
	mpd-responses(mpd-send-raw("list $type", $socket));
}

multi sub mpd-list (
	Str $type,
	Str $group-type,
	IO::Socket::INET $socket
) is export {
	mpd-responses(mpd-send-raw("list $type group $group-type", $socket));
}

multi sub mpd-listall (
	IO::Socket::INET $socket
	--> Array
) is export {
	parse-listall-lines(mpd-send-raw("listall", $socket));
}

multi sub mpd-listall (
	Str $uri,
	IO::Socket::INET $socket
	--> Array
) is export {
	parse-listall-lines(mpd-send-raw("listall $uri", $socket));
}

multi sub mpd-listallinfo (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listallinfo", $socket));
}

multi sub mpd-listallinfo (
	Str $uri,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listallinfo $uri", $socket));
}

multi sub mpd-listfiles (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listfiles", $socket));
}

multi sub mpd-listfiles (
	Str $uri,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("listfiles $uri", $socket));
}

multi sub mpd-lsinfo (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("lsinfo", $socket));
}

multi sub mpd-lsinfo (
	Str $uri,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("lsinfo $uri", $socket));
}

multi sub mpd-readcomments (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("readcomments", $socket));
}

multi sub mpd-readcomments (
	Str $uri,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("readcomments $uri", $socket));
}

multi sub mpd-search (
	Str $type,
	Str $what,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("search $type $what", $socket));
}

multi sub mpd-search (
	Str $type,
	Str $what,
	Str $sort-type,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("search $type $what sort $sort-type", $socket));
}

multi sub mpd-search (
	Str $type,
	Str $what,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("search $type $what window $start:$end", $socket));
}

multi sub mpd-search (
	Str $type,
	Str $what,
	Str $sort-type,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-responses(mpd-send-raw("search $type $what sort $sort-type window $start:$end", $socket));
}

sub mpd-searchadd (
	Str $type,
	Str $what,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send-raw("searchadd $type $what", $socket));
}

sub mpd-searchaddpl (
	Str $name,
	Str $type,
	Str $what,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("searchaddpl", [$name, $type, $what], $socket));
}

multi sub mpd-update (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("update", $socket));
}

multi sub mpd-update (
	Str $uri,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("update", $uri, $socket));
}

multi sub mpd-rescan (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("rescan", $socket));
}

multi sub mpd-rescan (
	Str $uri,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("rescan", $uri, $socket));
}

sub parse-listall-lines (
	IO::Socket::INET $socket
	--> Array
) {
	my Hash @entries;

	for $socket.lines -> $line {
		last if $line eq "OK";

		if ($line ~~ /(.+) ": " (.+)/) {
			@entries.push(%(
				type => $0.Str,
				path => $1.Str
			));
		}
	}

	@entries;
}
