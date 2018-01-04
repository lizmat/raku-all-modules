#! /usr/bin/env perl6

use v6.c;

use File::Temp;
use App::Assixt::Commands::New;
use App::Assixt::Commands::Touch::Test;
use Test;

multi sub MAIN { 0 }

my $root = tempdir;

chdir $root;

plan 2;

ok MAIN(
	"new",
	name => "Local::Test::Touch::Test",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "assixt new Local::Test::Touch::Test";

subtest "Touch test files", {
	my @tests = <
		some-shitty-test-file
		01-basic
	>;

	my $module-dir = "$root/perl6-Local-Test-Touch-Test";

	plan 2 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok MAIN("touch", "test", $test), "assixt touch test $test";
		ok "$module-dir/t/$test.t".IO.e, "t/$test.t exists";
	}
}

# vim: ft=perl6 noet
