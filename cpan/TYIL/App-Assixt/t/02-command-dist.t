#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Config;
use App::Assixt::Test;
use File::Temp;
use File::Which;
use Test;

plan 5;

skip-rest "'tar' is not available" and exit unless which("tar");

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

ok create-test-module($assixt, "Local::Test::Dist"), "assixt new Local::Test::Dist";
chdir "$root/perl6-Local-Test-Dist";

subtest "Create dist with normal config", {
	plan 2;

	ok run-bin($assixt, «
		--force
		dist
	»), "assixt dist";

	my $output-dir = get-config(:no-user-config)<assixt><distdir>;

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest "--output-dir overrides config-set output-dir", {
	plan 2;

	my Str $output-dir = "$root/output-alpha";

	ok run-bin($assixt, «
		--force
		dist
		"--output-dir=\"$output-dir\""
	»), "assixt dist --output-dir=$output-dir";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest "--output-dir set to a path with spaces", {
	plan 2;

	my Str $output-dir = "$root/output gamma";

	ok run-bin($assixt, «
		--force
		dist
		"--output-dir=\"$output-dir\""
	»), "assixt dist";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
}

subtest "Dist in other path can be created", {
	plan 2;

	my Str $output-dir = "$root/output-beta";

	chdir $root;

	ok run-bin($assixt, «
		--force
		dist
		perl6-Local-Test-Dist
		"--output-dir=\"$output-dir\""
	»), "cpan dist Local-Test-Dir";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

# vim: ft=perl6 noet
