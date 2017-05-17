#! /usr/bin/env false

use v6.c;

#| A simple exception class for resembling errors thrown by MPD.
class MPD::Client::Exceptions::MpdException is Exception
{
	has Str $.message;

	method new(Str $m)
	{
		self.bless(
			message => $m
		);
	}

	method message()
	{
		"MpdException: " ~ $!message;
	}
}
