#! /usr/bin/env perl6

use v6.c;
use lib "lib";
use Test;

plan 3;

use MPD::Client;
use MPD::Client::Status;

my $conn = mpd-connect(host => "localhost");

subtest "Ensure all the available fields are returned by mpd-status" => {
	my %response = mpd-status($conn);
	my @keys = [
		"consume",
		"duration",
		"error",
		"mixrampdb",
		"mixrampdelay",
		"nextsong",
		"nextsongid",
		"playlist",
		"playlistlength",
		"random",
		"repeat",
		"single",
		"song",
		"songid",
		"state",
		"updating_db",
		"volume",
		"xfade",
	];

	plan (@keys.end + 1);

	for @keys -> $key {
		ok %response{$key}:exists, "$key exists";
	}
}

subtest "Ensure all the available fields are returned by mpd-stats" => {
	my %response = mpd-stats($conn);
	my @keys = [
		"albums",
		"artists",
		"db_playtime",
		"db_update",
		"playtime",
		"songs",
		"uptime",
	];

	plan (@keys.end + 1);

	for @keys -> $key {
		ok %response{$key}:exists, "$key exists";
	}
}

ok mpd-clearerror($conn), "Errors get cleared correctly";
