#! /usr/bin/env perl6

use v6.c;

use File::Temp;
use App::Assixt::Config;
use App::Assixt::Test;
use Test;

plan 2;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

ok create-test-module($assixt, "Local::Test::Bootstrap::Config"), "assixt new Local::Test::Bootstrap Config";

subtest "Set configuration option", {
	plan 3;

	ok run-bin($assixt, «
		--force
		"--config-file=\"$root/assixt.toml\""
		bootstrap
		config
		assixt.distdir
		/tmp
	»), "assixt bootstrap config assixt.distdir /tmp";

	my $config = get-config(
		config-file => "$root/assixt.toml",
	);
	
	ok $config, "Written config loads correctly";
	is $config<assixt><distdir>, "/tmp", "Updated config option saved correctly";
};

# vim: ft=perl6 noet
