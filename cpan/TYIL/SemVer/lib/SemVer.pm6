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

		if (@parts.elems ≠ 3) {
			die "Incorrect number of arguments";
		}

		self.bless(
			major => @parts[0].Int,
			minor => @parts[1].Int,
			patch => @parts[2].Int,
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

	method Str
	{
		"{$!major}.{$!minor}.{$!patch}"
	}
}
