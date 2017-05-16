#! /usr/bin/env false

use v6.c;

grammar MPD::Client::Grammars::CurrentPlaylistLine {
	regex TOP {
		[
			<index>
			":file:"
			<.ws>
			<path>
		]
	}

	token index { <[\d]>+ }
	token path { <[\S\h]>+ }
}
