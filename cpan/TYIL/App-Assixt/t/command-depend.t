#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::New;
use App::Assixt::Commands::Depend;
use Dist::Helper::Meta;
use File::Temp;
use Test;

multi sub MAIN { 0 }

my $root = tempdir;

chdir $root;

plan 2;

ok MAIN(
	"new",
	name => "Local::Test::Depend",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "assixt new Local::Test::Depend";

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
		ok MAIN("depend", $test, :no-install), "assixt depend $test";

		chdir $module-dir;

		ok get-meta()<depends> ∋ $test, "META6.json contains $test";
	}
}

# vim: ft=perl6 noet
