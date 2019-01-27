#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Depend;
use App::Assixt::Commands::Undepend;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 2;

my Config $config = get-config(:!user-config).read: %(
	runtime => %(
		:no-install,
	),
);

subtest "Remove single dependency", {
	plan 4;

	my IO::Path $module = create-test-module("Local::Test::Undepend::Single", tempdir.IO);
	my Config $local-config = $config.clone.read: %(
		cwd => $module,
	);

	App::Assixt::Commands::Depend.run(
		"Config:api<0>:ver<1.3.5+>",
		"Test",
		"Test::META",
		config => $local-config,
	);

	my %meta = $module.&get-meta;

	is %meta<depends>.elems, 3, "Module has 3 dependencies";
	ok %meta<depends> (cont) "Config:api<0>:ver<1.3.5+>", "Config is included in depends";

	App::Assixt::Commands::Undepend.run("Config", config => $local-config);

	%meta = $module.&get-meta;

	ok %meta<depends> !(cont) "Config:api<0>:ver<1.3.5+>", "Config is no longer included in depends";
	is %meta<depends>.elems, 2, "Module has 2 dependencies";
}

subtest "Remove multiple dependencies", {
	plan 4;

	my IO::Path $module = create-test-module("Local::Test::Undepend::Multiple", tempdir.IO);
	my Config $local-config = $config.clone.read: %(
		cwd => $module,
	);

	App::Assixt::Commands::Depend.run(
		"Config:api<0>:ver<1.3.5+>",
		"Test",
		"Test::META",
		config => $local-config,
	);

	my %meta = $module.&get-meta;

	is %meta<depends>.elems, 3, "Module has 3 dependencies";
	ok %meta<depends> (cont) "Test", "Test is included in depends";
	ok %meta<depends> (cont) "Test::META", "Test::META is included in depends";

	App::Assixt::Commands::Undepend.run("Test", "Test::META", config => $local-config);

	%meta = $module.&get-meta;

	is %meta<depends>.elems, 1, "Module has 1 dependency";
}

# vim: ft=perl6 noet
