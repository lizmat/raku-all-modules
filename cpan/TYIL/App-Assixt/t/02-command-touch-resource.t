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

ok create-test-module($assixt, "Local::Test::Touch::Resource"), "assixt new Local::Test::Touch::Resource";
chdir "$root/perl6-Local-Test-Touch-Resource";

subtest "Touch unit files", {
	my @tests = <
		first
		second/level
		third/level/test
	>;

	my $module-dir = "$root/perl6-Local-Test-Touch-Resource";

	plan 4 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok get-meta()<resources> ∌ $test, "META6.json does not contain $test yet";
		ok run-bin($assixt, « touch resource $test »), "assixt touch resource $test";

		chdir $module-dir;

		my %new-meta = get-meta;

		ok %new-meta<resources> ∋ $test, "$test exists in META6.json<provides>";
		ok "resources/$test", "Resource $test exists";
	}
}

# vim: ft=perl6 noet
