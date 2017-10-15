#! /usr/bin/env false

use v6.c;

grammar MPD::Client::Grammars::PlaylistLine {
	regex TOP {
		[
			"file:"
			<.ws>
			<path>
		]
	}

	token path { <[\S\h]>+ }
}
