#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Touch::Resource;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 1;

my IO::Path $module = create-test-module("Local::Test::Touch::Resource", tempdir.IO);
my Config $config = get-config.read: %(
	cwd => $module,
);

subtest "Touch unit files", {
	my @tests = <
		first
		second/level
		third/level/test
	>;

	plan 3 × @tests.elems;

	for @tests -> $test {
		ok get-meta($module)<resources> ∌ $test, "META6.json does not contain $test yet";

		App::Assixt::Commands::Touch::Resource.run($test, :$config);

		my %new-meta = get-meta($module);

		ok %new-meta<resources> ∋ $test, "$test exists in META6.json<provides>";
		ok "resources/$test", "Resource $test exists";
	}
}

# vim: ft=perl6 noet
