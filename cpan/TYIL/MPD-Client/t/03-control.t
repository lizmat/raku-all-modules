#! /usr/bin/env perl6

use v6.c;
use lib "lib";
use Test;

plan 9;

use MPD::Client;
use MPD::Client::Control;
use MPD::Client::Util;

my $conn = mpd-connect(host => "localhost");

subtest "next" => {
	# todo: Add tests for mpd-next
	done-testing;
}

subtest "pause" => {
	# todo: Add tests for mpd-pause
	done-testing;
}

subtest "play" => {
	# todo: Add tests for mpd-play
	# The following 4 keys should be tested for existance in the mpd-status
	# call. These should be set when music is playing.
	# "audio",
	# "time",
	# "elapsed",
	# "bitrate",

	done-testing;
}

subtest "playid" => {
	# todo: Add tests for mpd-playid
	done-testing;
}

subtest "previous" => {
	# todo: Add tests for mpd-previous
	done-testing;
}

subtest "seek" => {
	# todo: Add tests for mpd-seek
	done-testing;
}

subtest "seekid" => {
	# todo: Add tests for mpd-seekid
	done-testing;
}

subtest "seekcur" => {
	# todo: Add tests for mpd-seekcur
	done-testing;
}

subtest "stop" => {
	# todo: Add tests for mpd-stop
	done-testing;
}
