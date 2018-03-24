#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

plan 4;

ok create-test-module($assixt, "Local::Test::Clean"), "assixt new Local::Test::Clean";
chdir "$root/perl6-Local-Test-Clean";

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
	ok run-bin($assixt, « --force clean »), "Command runs succesful";
	nok "resources/alpha".IO.e, "Orphan file has been deleted";
	nok get-meta()<provides><Local::Test::Clean::Orphan>:exists, "Unavailable provides reference has been removed";
}

subtest "assixt --no-files clean", {
	plan 3;

	# Setup
	mkdir "resources";
	spurt "resources/beta", "";
	put-meta(:%meta);

	# Test
	ok run-bin($assixt, « --force clean --no-files »), "Command runs succesful";
	ok "resources/beta".IO.e, "Orphan file was skipped";
	nok get-meta()<provides><Local::Test::Clean::Orphan>:exists, "Unavailable provides reference has been removed";
}

subtest "assixt --no-meta clean", {
	plan 3;

	# Setup
	mkdir "resources";
	spurt "resources/gamma", "";
	put-meta(:%meta);

	# Test
	ok run-bin($assixt, « --force clean --no-meta »), "Command runs succesful";
	nok "resources/gamma".IO.e, "Orphan file has been deleted";
	ok get-meta()<provides><Local::Test::Clean::Orphan>:exists, "Unaivalable provides reference was skipped";
}

# vim: ft=perl6 noet
