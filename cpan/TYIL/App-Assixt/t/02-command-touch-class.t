#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Touch::Class;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 1;

my IO::Path $module = create-test-module("Local::Test::Touch::Lib::Class", tempdir.IO);
my Config $config = get-config(:!user-config).read: %(
	cwd => $module,
);

subtest "Touch class files", {
	my @tests = <
		First
		Second::Level
		Third::Level::Test
	>;

	plan 3 × @tests.elems;

	for @tests -> $test {
		ok get-meta($module)<provides>{$test}:!exists, "META6.json does not contain $test yet";

		App::Assixt::Commands::Touch::Class.run($test, :$config);

		my %new-meta = get-meta($module);

		ok %new-meta<provides>{$test}:exists, "$test exists in META6.json<provides>";
		ok $module.add(%new-meta<provides>{$test}).e, "{%new-meta<provides>{$test}} exists";
	}
}

# vim: ft=perl6 noet
