#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Config;
use App::Assixt::Test;
use File::Temp;
use File::Which;

plan 2;

skip-rest "'a2x' is not available" and exit unless which("a2x");
skip-rest "'gzip' is not available" and exit unless which("gzip");

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

ok create-test-module($assixt, "Local::Test::Bootstrap::Man"), "assixt new Local::Test::Bootstrap::Man";

subtest "Build manpages", {
	plan 2;

	ok run-bin($assixt, «
		bootstrap
		man
		"--dir=\"$root\""
	»), "assixt bootstrap man";

	ok "$root/man1/assixt.1.gz".IO.e, "assixt.1.gz built";
};

# vim: ft=perl6 noet
