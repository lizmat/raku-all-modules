#! /usr/bin/env perl6

use v6.c;

use File::Temp;
use App::Assixt::Commands::Bootstrap::Config;
use App::Assixt::Commands::New;
use App::Assixt::Config;
use Test;

plan 2;

multi sub MAIN { 0 }

my $root = tempdir;

chdir $root;

ok MAIN(
	"new",
	name => "Local::Test::Bootstrap::Config",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "assixt new Local::Test::Bootstrap Config";

subtest "Set configuration option", {
	plan 3;

	ok MAIN(
		"bootstrap",
		"config",
		"assixt.distdir",
		"/tmp",
		config-file => "$root/assixt.toml",
		force => True,
	), "assixt bootstrap config assixt.distdir /tmp";

	my $config = get-config(
		config-file => "$root/assixt.toml",
	);

	ok $config, "Written config loads correctly";
	is $config<assixt><distdir>, "/tmp", "Updated config option saved correctly";
};

# vim: ft=perl6 noet
