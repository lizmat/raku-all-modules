#! /usr/bin/env perl6

use v6.c;

use App::Cpan6::Commands::New;
use App::Cpan6::Commands::Depend;
use App::Cpan6::Meta;
use File::Temp;
use Test;

multi sub MAIN { 0 }

# Disable git
%*ENV<CPAN6_EXTERNAL_GIT> = False;

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
), "cpan6 new Local::Test::Depend";

subtest "Touch unit files", {
	my @tests = <
		Config
		App::Cpan6
		Config::Parser::toml
	>;

	my $module-dir = "$root/perl6-Local-Test-Depend";

	plan 3 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok get-meta()<depends> ∌ $test, "META6.json does not contain $test yet";
		ok MAIN("depend", $test, :no-install), "cpan6 depend $test";

		chdir $module-dir;

		ok get-meta()<depends> ∋ $test, "META6.json contains $test";
	}
}

# vim: ft=perl6 noet
