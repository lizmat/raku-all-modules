#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Touch::Test;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use File::Temp;

plan 1;

my IO::Path $module = create-test-module("Local::Test::Touch::Test", tempdir.IO);
my Config $config = get-config.read: %(
	cwd => $module,
);

subtest "Touch test files", {
	my @tests = <
		some-shitty-test-file
		01-basic
	>;

	plan @tests.elems;

	for @tests -> $test {
		App::Assixt::Commands::Touch::Test.run($test, :$config);

		ok $module.add("t").add("$test.t").e, "t/$test.t exists";
	}
}

# vim: ft=perl6 noet
