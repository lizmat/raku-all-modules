#! /usr/bin/env false

use v6.c;

use MPD::Client::Exceptions::SocketException;

unit module MPD::Client;

#| Connect to a running MPD instance over TCP.
sub mpd-connect (
	Str :$host = "127.1",
	Int :$port = 6600
	--> IO::Socket::INET
) is export {
	my $socket = IO::Socket::INET.new(host => $host, port => $port);
	my $response = $socket.get();

	if ($response eq "") {
		MPD::Exceptions::SocketException.new("Empty response").throw();
	}

	if ($response !~~ m/OK\sMPD\s.+/) {
		my $error = "Incorrect response string '" ~ $response ~ "'";

		MPD::Exceptions::SocketException.new($error).throw();
	}

	$socket;
}
