#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Clean;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 3;

my IO::Path $module = create-test-module("Local::Test::Clean", tempdir.IO);
my Config $config = get-config.read: %(
	:force,
);

# Create a non-clean META6.json
my %meta = $module.&get-meta;

%meta<provides><Local::Test::Clean::Orphan> = "lib/non-existant.pm6";

subtest "assixt clean", {
	plan 2;

	mkdir $module.add("resources");
	spurt $module.add("resources/alpha"), "";
	put-meta(%meta, $module);

	App::Assixt::Commands::Clean.run($module, :$config);

	nok $module.add("resources/alpha").e, "Orphan file has been deleted";
	nok $module.&get-meta()<provides><Local::Test::Clean::Orphan>:exists, "Unavailable provides reference has been removed";
}

subtest "assixt --no-files clean", {
	plan 2;

	mkdir $module.add("resources");
	spurt $module.add("resources/beta"), "";
	put-meta(%meta, $module);

	App::Assixt::Commands::Clean.run($module, config => $config.clone.read: %(
		runtime => %(
			:no-files,
		),
	));

	ok $module.add("resources/beta").e, "Orphan file was skipped";
	nok $module.&get-meta()<provides><Local::Test::Clean::Orphan>:exists, "Unavailable provides reference has been removed";
}

subtest "assixt --no-meta clean", {
	plan 2;

	mkdir $module.add("resources");
	spurt $module.add("resources/gamma"), "";
	put-meta(%meta, $module);

	App::Assixt::Commands::Clean.run($module, config => $config.clone.read: %(
		runtime => %(
			:no-meta,
		),
	));

	nok $module.add("resources/gamma").e, "Orphan file has been deleted";
	ok $module.&get-meta()<provides><Local::Test::Clean::Orphan>:exists, "Unavailable provides reference was skipped";
}

# vim: ft=perl6 noet
