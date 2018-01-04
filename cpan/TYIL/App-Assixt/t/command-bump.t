#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::Bump;
use App::Assixt::Commands::New;
use Dist::Helper::Meta;
use File::Temp;
use Test;

plan 4;

multi sub MAIN { 0 }

my $root = tempdir;

chdir $root;

ok MAIN(
	"new",
	name => "Local::Test::Bump",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "assixt new Local::Test::Bump";

subtest "Bump patch version", {
	plan 3;

	is get-meta()<version>, "0.0.0", "Version is now at 0.0.0";
	ok MAIN("bump", "patch", :force), "Bump patch level";
	is get-meta()<version>, "0.0.1", "Version is now at 0.0.1";
};

subtest "Bump minor version", {
	plan 3;

	is get-meta()<version>, "0.0.1", "Version is now at 0.0.1";
	ok MAIN("bump", "minor", :force), "Bump minor level";
	is get-meta()<version>, "0.1.0", "Version is now at 0.1.0";
};

subtest "Bump major version", {
	plan 3;

	is get-meta()<version>, "0.1.0", "Version is now at 0.1.0";
	ok MAIN("bump", "major", :force), "Bump major level";
	is get-meta()<version>, "1.0.0", "Version is now at 1.0.0";
};

# vim: ft=perl6 noet
