#! /usr/bin/env perl6

use v6.c;

use File::Temp;
use App::Cpan6::Commands::New;
use App::Cpan6::Commands::Touch::Test;
use Test;

multi sub MAIN { 0 }

# Disable git
%*ENV<CPAN6_EXTERNAL_GIT> = False;

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
), "cpan6 new Local::Test::Touch::Test";

subtest "Touch test files", {
	my @tests = <
		some-shitty-test-file
		01-basic
	>;

	my $module-dir = "$root/perl6-Local-Test-Touch-Test";

	plan 2 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok MAIN("touch", "test", $test), "cpan6 touch test $test";
		ok "$module-dir/t/$test.t".IO.e, "t/$test.t exists";
	}
}

# vim: ft=perl6 noet
