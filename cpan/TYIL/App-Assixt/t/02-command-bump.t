#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;

plan 4;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

ok create-test-module($assixt, "Local::Test::Bump"), "assixt new Local::Test::Bump";

chdir "$root/perl6-Local-Test-Bump";

subtest "Bump patch version", {
	plan 3;

	is get-meta()<version>, "0.0.0", "Version is now at 0.0.0";
	ok run-bin($assixt, « bump patch --force »), "Bump patch level";
	is get-meta()<version>, "0.0.1", "Version is now at 0.0.1";
};

subtest "Bump minor version", {
	plan 3;

	is get-meta()<version>, "0.0.1", "Version is now at 0.0.1";
	ok run-bin($assixt, « bump minor --force »), "Bump minor level";
	is get-meta()<version>, "0.1.0", "Version is now at 0.1.0";
};

subtest "Bump major version", {
	plan 3;

	is get-meta()<version>, "0.1.0", "Version is now at 0.1.0";
	ok run-bin($assixt, « bump major --force »), "Bump major level";
	is get-meta()<version>, "1.0.0", "Version is now at 1.0.0";
};

# vim: ft=perl6 noet
