#! /usr/bin/env perl6

use v6.c;

use File::Temp;
use IO::Path::Dirstack;
use Test;

plan 1;

# Prepare a number of dirs to chdir to
my @dirs = tempdir() xx 4;
my $cwd = ~$*CWD;

subtest "pushd", {
	plan @dirs.elems;

	for @dirs -> $dir {
		subtest "pushd $dir", {
			plan 2;

			ok pushd($dir), "pushd returns true";
			is ~$*CWD, $dir, "Changed directory correctly"
		}
	}
}

subtest "popd", {
	plan @dirs.elems;

	for @dirs.reverse.kv -> $i, $dir {
		subtest "popd", {
			plan 3;

			is ~$*CWD, $dir, "Current dir is correct";
			ok popd(), "popd returns true";

			if ($i < @dirs.elems - 1) {
				is ~$*CWD, @dirs[@dirs.elems - $i - 2], "Current dir is previous dir";
			} else {
				is ~$*CWD, $cwd, "Current dir is starting dir";
			}
		}
	}
}

# vim: ft=perl6 noet
