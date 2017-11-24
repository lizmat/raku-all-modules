#! /usr/bin/env false

use v6.c;

class SemVer
{
	has Int $.major;
	has Int $.minor;
	has Int $.patch;

	multi method new()
	{
		self.bless(
			major => 0,
			minor => 0,
			patch => 0,
		);
	}

	multi method new(Str $version where /\d+\.\d+\.\d+/)
	{
		my @parts = $version.split(".");

		die "Incorrect number of arguments" if @parts.elems ≠ 3;

		self.bless(
			major => +@parts[0],
			minor => +@parts[1],
			patch => +@parts[2],
		);
	}

	multi method new(Int:D $major, Int:D $minor, Int:D $patch)
	{
		self.bless(
			:$major,
			:$minor,
			:$patch
		);
	}

	method bump-major()
	{
		$!major++;
		$!minor = 0;
		$!patch = 0;
	}

	method bump-minor()
	{
		$!minor++;
		$!patch = 0;
	}

	method bump-patch()
	{
		$!patch++;
	}

	method gist(--> Str)
	{
		"{$!major}.{$!minor}.{$!patch}"
	}

	method Str(--> Str)
	{
		self.gist
	}
}
