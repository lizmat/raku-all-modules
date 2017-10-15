#! /usr/bin/env false

use v6.c;

#| A simple exception class for dealing with all issues that can arise from
#| connecting or interacting with the MPD socket.
class MPD::Client::Exceptions::ArgumentException is Exception
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
		"ArgumentException: " ~ $!message;
	}
}
