#! /usr/bin/env false

use v6.c;

unit module IO::Path::Dirstack;

my IO::Path @dirstack = [];

sub popd (
	--> Bool
) is export {
	my $dir = @dirstack.pop;
	my $change = chdir $dir;

	if ($change ~~ Failure) {
		@dirstack.push: $dir;

		return $change;
	}

	True;
}

multi sub pushd (
	Str:D $dir,
	--> Bool
) is export {
	pushd($dir.IO)
}

multi sub pushd (
	IO::Path:D $dir,
	--> Bool
) is export {
	my $cwd = $*CWD;
	my $change = chdir $dir;

	return $change if $change ~~ Failure;

	@dirstack.push: $cwd;

	True;
}

# vim: ft=perl6 noet
