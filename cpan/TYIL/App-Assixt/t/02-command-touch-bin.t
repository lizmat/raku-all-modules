#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Touch::Bin;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 1;

my IO::Path $module = create-test-module("Local::Test::Touch::Bin", tempdir.IO);

subtest "Touch bin files", {
	my @tests = <
		first
		second-bin
	>;

	plan 4 × @tests.elems;

	for @tests -> $test {
		ok $module.&get-meta()<provides>{$test}:!exists, "META6.json does not contain $test yet";

		my IO::Path $file = App::Assixt::Commands::Touch::Bin.run($test, config => get-config().read: %(
			cwd => $module,
		));

		ok $module.&get-meta()<provides>{$test}:exists, "$test exists in META6.json<provides>";
		is $module.&get-meta()<provides>{$test}, $file.relative($module), "$test provides the correct path";
		ok $module.add($module.&get-meta()<provides>{$test}).e, "$file.basename() exists";
	}
}

# vim: ft=perl6 noet
