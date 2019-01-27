#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Depend;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 1;

my IO::Path $module = create-test-module("Local::Test::Depend", tempdir.IO);
my Config $config = get-config().read: %(
	cwd => $module,
	runtime => %(
		:no-install,
	),
);

subtest "Touch unit files", {
	my @tests = <
		Config
		App::Assixt
		Config::Parser::toml
	>;

	plan 2 × @tests.elems;

	for @tests -> $test {
		ok $module.&get-meta()<depends> ∌ $test, "META6.json does not contain $test yet";

		App::Assixt::Commands::Depend.run($test, :$config);

		ok $module.&get-meta()<depends> ∋ $test, "META6.json contains $test";
	}
}

# vim: ft=perl6 noet
