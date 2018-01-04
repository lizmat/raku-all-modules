#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::Clean;
use App::Assixt::Commands::New;
use Dist::Helper::Meta;
use File::Temp;
use Test;

multi sub MAIN { 0 }

my $root = tempdir;

chdir $root;

plan 4;

ok MAIN(
	"new",
	name => "Local::Test::Clean",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "assixt new Local::Test::Clean";

# Create a non-clean META6.json
my %meta = get-meta;
%meta<provides><Local::Test::Clean::Orphan> = "lib/non-existant.pm6";

subtest "assixt clean", {
	plan 3;

	# Setup
	mkdir "resources";
	spurt "resources/alpha", "";
	put-meta(:%meta);

	# Test
	ok MAIN("clean", :force);
	nok "resources/alpha".IO.e;
	nok get-meta()<provides><Local::Test::Clean::Orphan>:exists;
}

subtest "assixt --no-files clean", {
	plan 3;

	# Setup
	mkdir "resources";
	spurt "resources/beta", "";
	put-meta(:%meta);

	# Test
	ok MAIN("clean", :force, :no-files);
	ok "resources/beta".IO.e;
	nok get-meta()<provides><Local::Test::Clean::Orphan>:exists;
}

subtest "assixt --no-meta clean", {
	plan 3;

	# Setup
	mkdir "resources";
	spurt "resources/gamma", "";
	put-meta(:%meta);

	# Test
	ok MAIN("clean", :force, :no-meta);
	nok "resources/gamma".IO.e;
	ok get-meta()<provides><Local::Test::Clean::Orphan>:exists;
}

# vim: ft=perl6 noet
