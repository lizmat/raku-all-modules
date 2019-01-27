#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Config;
use App::Assixt::Test;
use App::Assixt::Commands::Touch::Meta;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 2;

my IO::Path $module = create-test-module("Local::Test::Touch::Meta", tempdir.IO);
my Config $config = get-config.read: %(
	cwd => $module,
);

subtest "Create clean README", {
	plan 2;

	unlink $module.add("README.pod6"); # Remove default README.pod6

	nok $module.add("README.pod6").e, "README.pod6 does not exist";

	App::Assixt::Commands::Touch::Meta.run("readme", :$config);

	ok $module.add("README.pod6").f, "README.pod6 created";
}

subtest "Recreate clean gitlab-ci configuration", {
	plan 2;

	my IO::Path $file = App::Assixt::Commands::Touch::Meta.run("gitlab-ci", config => $config.clone.read: %(
		:force,
	));

	ok $file, "Command ran correctly";
	ok $module.add(".gitlab-ci.yml").f, ".gitlab-ci.yml created";
}

# vim: ft=perl6 noet
