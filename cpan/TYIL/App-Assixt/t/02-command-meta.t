#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::Meta;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;
use Test::Output;
use Test;

plan 5;

my IO::Path $module = create-test-module("Test::Meta::SourceUrl", tempdir.IO, %(
	runtime => %(
		auth => "",
	),
));
my Config $config = get-config(:!user-config).read: %(
	cwd => $module,
);

subtest "Error messages", {
	plan 1;

	output-like {
		App::Assixt::Commands::Meta.run(config => get-config(:!user-config));
	}, / "check the App::Assixt::Commands::Meta" .+ "documentation" /, "Reference to the documentation is shown";
}

subtest "auth", {
	plan 2;

	is get-meta($module.absolute)<auth>, "", "Auth is empty";

	App::Assixt::Commands::Meta.run("auth", "gitlab:tyil", :$config);

	is get-meta($module.absolute)<auth>, "gitlab:tyil", "Auth got updated";
}

subtest "description", {
	plan 2;

	is get-meta($module.absolute)<description>, "Nondescript", "Description is Nondescript";

	App::Assixt::Commands::Meta.run("description", "This is a test description!", :$config);

	is get-meta($module.absolute)<description>, "This is a test description!", "Description got updated";
}

subtest "license", {
	plan 2;

	is get-meta($module.absolute)<license>, "AGPL-3.0", "License is AGPL-3.0";

	App::Assixt::Commands::Meta.run("license", "Artistic-2.0", :$config);

	is get-meta($module.absolute)<license>, "Artistic-2.0", "License got updated";
}

subtest "source-url", {
	plan 2;

	is get-meta($module.absolute)<source-url>, "Localhost", "Source-url is Localhost";

	App::Assixt::Commands::Meta.run("source-url", "tyil.nl", :$config);

	is get-meta($module.absolute)<source-url>, "tyil.nl", "Source-url got updated";
}

# vim: ft=perl6 noet
