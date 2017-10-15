#! /usr/bin/env false

use v6.c;

grammar MPD::Client::Grammars::AckLine {
	rule TOP {
		[
			"ACK"
			"["
			<code>
			"]"
			<message>
		]
	}

	token code { \d ** 2 "@" \d }
	token message { .+ }
}
