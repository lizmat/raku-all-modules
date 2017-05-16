#! /usr/bin/env false

use v6.c;

grammar MPD::Client::Grammars::ResponseLine {
	regex TOP {
		[
			<key>
			":"
			<.ws>
			<value>
		]
	}

	token key { <[\S]-[:]>+ }
	token value { <[\S\h]>+ }
}
