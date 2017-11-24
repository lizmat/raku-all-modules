#! /usr/bin/env false

use v6.c;

use App::Cpan6::Config;
use File::Which;

unit module App::Cpan6::External;

sub external-git(
	Bool:D :$no-user-config = False,
	Str:D :$root = ".",
	--> Bool
) is export {
	return False unless get-config(:$no-user-config)<external><git>;
	return False unless $root.IO.add(".git").d;
	return False unless which("git");

	True;
}

# vim: ft=perl6 noet
