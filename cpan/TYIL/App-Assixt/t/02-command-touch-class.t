#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

plan 2;

ok create-test-module($assixt, "Local::Test::Touch::Lib::Class"), "assixt new Local::Test::Touch::Lib::Class";
chdir "$root/perl6-Local-Test-Touch-Lib-Class";

subtest "Touch class files", {
	my @tests = <
		First
		Second::Level
		Third::Level::Test
	>;

	plan 4 × @tests.elems;

	for @tests -> $test {
		ok get-meta()<provides>{$test}:!exists, "META6.json does not contain $test yet";
		ok run-bin($assixt, « touch class $test »), "assixt touch class $test";

		my %new-meta = get-meta;

		ok %new-meta<provides>{$test}:exists, "$test exists in META6.json<provides>";
		ok %new-meta<provides>{$test}.IO.e, "{%new-meta<provides>{$test}} exists";
	}
}

# vim: ft=perl6 noet
