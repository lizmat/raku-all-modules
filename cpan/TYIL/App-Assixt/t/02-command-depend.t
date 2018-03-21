#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;
use Test;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

plan 2;

ok create-test-module($assixt, "Local::Test::Depend"), "assixt new Local::Test::Depend";
chdir "$root/perl6-Local-Test-Depend";

subtest "Touch unit files", {
	my @tests = <
		Config
		App::Assixt
		Config::Parser::toml
	>;

	my $module-dir = "$root/perl6-Local-Test-Depend";

	plan 3 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok get-meta()<depends> ∌ $test, "META6.json does not contain $test yet";
		ok run-bin($assixt, « depend $test --no-install »), "assixt depend $test";

		chdir $module-dir;

		ok get-meta()<depends> ∋ $test, "META6.json contains $test";
	}
}

# vim: ft=perl6 noet
