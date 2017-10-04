#! /usr/bin/env false

use v6.c;

use MPD::Client::Util;

unit module MPD::Client::Current;

sub mpd-add (
	Str $uri,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("add", $uri, $socket));
}

sub mpd-addid (
	Str $uri,
	IO::Socket::INET $socket
	--> Hash
) is export {
	$socket
		==> mpd-send("addid", $uri)
		==> transform-response-ints(["Id"])
		;
}

sub mpd-clear (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("clear", $socket));
}

multi sub mpd-delete (
	Int $pos,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("delete", $pos, $socket));
}

multi sub mpd-delete (
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("delete", "$start:$end", $socket));
}

sub mpd-deleteid (
	Int $songid,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("deleteid", $songid, $socket));
}

multi sub mpd-move (
	Int $from,
	Int $to,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("move", [$from, $to], $socket));
}

multi sub mpd-move (
	Int $start,
	Int $end,
	Int $to,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("move", ["$start:$end", $to], $socket));
}

sub mpd-moveid (
	Int $songid,
	Int $to,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("moveid", [$songid, $to], $socket));
}

sub mpd-playlist (
	IO::Socket::INET $socket
	--> Array
) is export {
	mpd-send-raw("playlist", $socket);

	my @playlist;

	for $socket.get() -> $line {
		if ($line eq "OK") {
			last;
		}

		if (my $match = MPD::Client::Grammars::CurrentPlaylistLine.parse($line)) {
			@playlist.push($match<path>);
		}
	}

	@playlist;
}

sub mpd-playlistfind (
	Str $tag,
	Str $needle,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistfind $tag $needle")
		==> search-response-list()
		;
}

multi sub mpd-playlistid (
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistid")
		==> search-response-list()
		;
}

multi sub mpd-playlistid (
	Int $songid,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistid $songid")
		==> search-response-list()
		;
}

multi sub mpd-playlistinfo (
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistinfo")
		==> search-response-list()
		;
}

multi sub mpd-playlistinfo (
	Int $songpos,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistinfo $songpos")
		==> search-response-list()
		;
}

multi sub mpd-playlistinfo (
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistinfo $start:$end")
		==> search-response-list()
		;
}

sub mpd-playlistsearch (
	Str $tag,
	Str $needle,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("playlistsearch $tag $needle")
		==> search-response-list()
		;
}

multi sub mpd-plchanges (
	Int $version,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("plchanges $version")
		==> search-response-list()
		;
}

multi sub mpd-plchanges (
	Int $version,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("plchanges $version $start:$end")
		==> search-response-list()
		;
}

multi sub mpd-plchangesposid (
	Int $version,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("plchangesposid $version")
		==> search-response-list()
		;
}

multi sub mpd-plchangesposid (
	Int $version,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Array
) is export {
	$socket
		==> mpd-send-raw("plchangesposid $version $start:$end")
		==> search-response-list()
		;
}

sub mpd-prio (
	Int $priority,
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("prio", "$start:$end", $socket));
}

sub mpd-prioid (
	Int $priority,
	Int $id,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("prioid", $id, $socket));
}

multi sub mpd-rangeid (
	Int $id,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("rangeid", [$id, ":"], $socket));
}

multi sub mpd-rangeid (
	Int $id,
	Real $start,
	Real $end,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("rangeid", [$id, "$start:$end"], $socket));
}

multi sub mpd-shuffle (
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("shuffle", $socket));
}

multi sub mpd-shuffle (
	Int $start,
	Int $end,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("shuffle", "$start:$end", $socket));
}

sub mpd-swap (
	Int $song1,
	Int $song2,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("swap", [$song1, $song2], $socket));
}

sub mpd-swapid (
	Int $song1,
	Int $song2,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("swapid", [$song1, $song2], $socket));
}

sub mpd-addtagid (
	Int $songid,
	Str $tag,
	Any $value,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("addtagid", [$songid, $tag, $value.Str], $socket));
}

multi sub mpd-cleartagid (
	Int $songid,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("cleartagid", $songid, $socket));
}

multi sub mpd-cleartagid (
	Int $songid,
	Str $tag,
	IO::Socket::INET $socket
	--> Bool
) is export {
	mpd-response-ok(mpd-send("cleartagid", [$songid, $tag], $socket));
}

#| Turn a response to a search query into an array of hits. Each element
#| is a Hash.
sub search-response-list (
	IO::Socket::INET $socket
	--> Array
) {
	my @hits;
	my $index = -1;

	for $socket.lines -> $line {
		if ($line eq "OK") {
			last;
		}

		if (my $match = MPD::Client::Grammars::ResponseLine.parse($line)) {
			if ($match<key> eq "file") {
				@hits[++$index] = {};
			}

			@hits[$index]{$match<key>} = $match<value>;
		}
	}

	@hits;
}
