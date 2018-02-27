#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::New;
use App::Assixt::Commands::Dist;
use App::Assixt::Config;
use File::Temp;
use File::Which;
use Test;

plan 5;

skip-rest "'tar' is not available" and exit unless which("tar");

multi sub MAIN { 0 }

my $root = tempdir;

chdir $root;

ok MAIN(
	"new",
	name => "Local::Test::Dist",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "assixt new Local::Test::Dist";

subtest "Create dist with normal config", {
	plan 2;

	ok MAIN(
		"dist",
		:force,
	), "assixt dist";

	my $output-dir = get-config(:no-user-config)<assixt><distdir>;

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest ":output-dir overrides config-set output-dir", {
	plan 2;

	my Str $output-dir = "$root/output-alpha";

	ok MAIN(
		"dist",
		:$output-dir,
	), "assixt dist";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest ":output-dir set to a path with spaces", {
	plan 2;

	my Str $output-dir = "$root/output gamma";

	ok MAIN(
		"dist",
		:$output-dir,
	), "assixt dist";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
}

subtest "Dist in other path can be created", {
	plan 2;

	my Str $output-dir = "$root/output-beta";

	chdir $root;

	ok MAIN(
		"dist",
		"perl6-Local-Test-Dist",
		:$output-dir,
	), "cpan dist Local-Test-Dir";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

# vim: ft=perl6 noet
