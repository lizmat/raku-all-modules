#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Test;
use File::Temp;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

plan 2;

ok create-test-module($assixt, "Local::Test::Touch::Test"), "assixt new Local::Test::Touch::Test";
chdir "$root/perl6-Local-Test-Touch-Test";

subtest "Touch test files", {
	my @tests = <
		some-shitty-test-file
		01-basic
	>;

	my $module-dir = "$root/perl6-Local-Test-Touch-Test";

	plan 2 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok run-bin($assixt, « touch test $test »), "assixt touch test $test";
		ok "$module-dir/t/$test.t".IO.e, "t/$test.t exists";
	}
}

# vim: ft=perl6 noet
