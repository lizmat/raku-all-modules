#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Bootstrap::Config;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use File::Temp;

plan 1;

my IO::Path $module = create-test-module("Local::Test::Bootstrap::Config", tempdir.IO);
my Config $config = get-config(:!user-config).read: %(
	:force,
	config-file => (tempfile)[0] ~ ".toml",
);

subtest "Set configuration option", {
	plan 2;

	App::Assixt::Commands::Bootstrap::Config.run("assixt.distdir", "/tmp", :$config);

	my Config $updated-config = get-config(
		:!user-config,
		config-file => $config<config-file>,
	);

	ok $updated-config, "Written config loads correctly";
	is $updated-config<assixt><distdir>, "/tmp", "Updated config option saved correctly";
}

# vim: ft=perl6 noet
