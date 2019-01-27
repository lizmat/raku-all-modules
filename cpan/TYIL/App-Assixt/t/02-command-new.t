#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Config;
use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;
use Config;
use App::Assixt::Commands::New;

plan 6;

my Config $config = get-config(:!user-config).read: %(
	cwd => tempdir.IO,
);

my %test-meta = %(
	author => "Patrick Spek",
	description => "Just another test module",
	email => "p.spek@tyil.work",
	license => "GPL-3.0",
	perl => "c",
	meta-version => 0,
	source-url => "localhost",
	auth => "gitlab:tyil",
);

subtest "Create a new module", {
	plan 7;

	my IO::Path $module = App::Assixt::Commands::New.run(config => $config.clone.read: %(
		runtime => %(
			name => "Local::Test::Module",
			author => %test-meta<author>,
			email => %test-meta<email>,
			perl => %test-meta<perl>,
			description => %test-meta<description>,
			license => %test-meta<license>,
			source-url => %test-meta<source-url>,
			auth => %test-meta<auth>,
		),
	));

	ok $module.d, "Module directory created";
	ok $module.add(".editorconfig").e, "Editorconfig created";
	ok $module.add(".gitignore").e, "Gitignore created";
	ok $module.add(".gitlab-ci.yml").e, "GitLab CI config created";
	ok $module.add(".travis.yml").e, "Travis config created";
	ok $module.add("CHANGELOG.md").e, "CHANGELOG created";

	subtest "Verify META6.json", {
		plan 12;

		my %meta = get-meta($module);

		is %meta<meta-version>, %test-meta<meta-version>, "meta-version is correct";
		is %meta<perl>, "6.%test-meta<perl>", "perl is correct";
		is %meta<name>, "Local::Test::Module", "name is correct";
		is %meta<description>, %test-meta<description>, "description is correct";
		is %meta<license>, %test-meta<license>, "license is correct";
		is %meta<version>, "0.0.0", "version is correct";
		is %meta<authors>, "{%test-meta<author>} <{%test-meta<email>}>", "author is correct";
		is %meta<source-url>, %test-meta<source-url>, "source-url is correct";
		is %meta<auth>, %test-meta<auth>, "auth is correct";
		is %meta<resources>.elems, 0, "resources is empty";
		is %meta<provides>.elems, 0, "provides is empty";
		is %meta<depends>.elems, 0, "depends is empty";
	}
};

subtest "Create a new module with force", {
	plan 7;

	my IO::Path $module = App::Assixt::Commands::New.run(config => $config.clone.read: %(
		:force,
		runtime => %(
			name => "Local::Test::Module",
			author => %test-meta<author>,
			email => %test-meta<email>,
			perl => "d",
			description => "Nondescript",
			license => %test-meta<license>,
			source-url => %test-meta<source-url>,
			auth => %test-meta<auth>,
		),
	));

	ok $module.d, "Module directory created";
	ok $module.add(".gitignore").e, "Gitignore created";
	ok $module.add(".gitlab-ci.yml").e, "GitLab CI config created";
	ok $module.add(".editorconfig").e, "Editorconfig created";
	ok $module.add(".travis.yml").e, "Travis config created";
	ok $module.add("CHANGELOG.md").e, "CHANGELOG created";

	subtest "Verify META6.json", {
		plan 12;

		my %meta = get-meta($module);

		is %meta<meta-version>, %test-meta<meta-version>, "meta-version is correct";
		is %meta<perl>, "6.d", "perl is correct";
		is %meta<name>, "Local::Test::Module", "name is correct";
		is %meta<description>, "Nondescript", "description is correct";
		is %meta<license>, %test-meta<license>, "license is correct";
		is %meta<version>, "0.0.0", "version is correct";
		is %meta<authors>, "{%test-meta<author>} <{%test-meta<email>}>", "author is correct";
		is %meta<source-url>, %test-meta<source-url>, "source-url is correct";
		is %meta<auth>, %test-meta<auth>, "auth is correct";
		is %meta<resources>.elems, 0, "resources is empty";
		is %meta<provides>.elems, 0, "provides is empty";
		is %meta<depends>.elems, 0, "depends is empty";
	}
};

subtest "Create a new module without gitignore", {
	plan 6;

	my IO::Path $module = App::Assixt::Commands::New.run(config => $config.clone.read: %(
		cwd => tempdir.IO,
		runtime => %(
			:no-git,
			name => "Local::Test::Module",
			author => %test-meta<author>,
			email => "6.d",
			perl => %test-meta<perl>,
			description => "Nondescript",
			license => %test-meta<license>,
			source-url => %test-meta<source-url>,
			auth => %test-meta<auth>,
		),
	));

	ok $module.d, "Module directory created";
	ok $module.add(".editorconfig").e, "Editorconfig created";
	ok $module.add(".gitlab-ci.yml").e, "GitLab CI config created";
	ok $module.add(".travis.yml").e, "Travis config created";
	ok $module.add("CHANGELOG.md").e, "CHANGELOG created";

	nok $module.add(".gitignore").e, "Gitignore missing";
};

subtest "Create a new module without Travis info", {
	plan 6;

	my IO::Path $module = App::Assixt::Commands::New.run(config => $config.clone.read: %(
		cwd => tempdir.IO,
		runtime => %(
			:no-travis,
			name => "Local::Test::Module",
			author => %test-meta<author>,
			email => "6.d",
			perl => %test-meta<perl>,
			description => "Nondescript",
			license => %test-meta<license>,
			source-url => %test-meta<source-url>,
			auth => %test-meta<auth>,
		),
	));

	ok $module.d, "Module directory created";
	ok $module.add(".editorconfig").e, "Editorconfig created";
	ok $module.add(".gitignore").e, "Gitignore created";
	ok $module.add(".gitlab-ci.yml").e, "GitLab CI config created";
	ok $module.add("CHANGELOG.md").e, "CHANGELOG created";

	nok $module.add(".travis.yml").e, "Travis config missing";
};

subtest "Create a new module without GitLab CI info", {
	plan 6;

	my IO::Path $module = App::Assixt::Commands::New.run(config => $config.clone.read: %(
		cwd => tempdir.IO,
		runtime => %(
			:no-gitlab-ci,
			name => "Local::Test::Module",
			author => %test-meta<author>,
			email => "6.d",
			perl => %test-meta<perl>,
			description => "Nondescript",
			license => %test-meta<license>,
			source-url => %test-meta<source-url>,
			auth => %test-meta<auth>,
		),
	));

	ok $module.d, "Module directory created";
	ok $module.add(".editorconfig").e, "Editorconfig created";
	ok $module.add(".gitignore").e, "Gitignore created";
	ok $module.add(".travis.yml").e, "Travis config created";
	ok $module.add("CHANGELOG.md").e, "CHANGELOG created";

	nok $module.add(".gitlab-ci.yml").e, "GitLab CI config missing";
};

subtest "Create a new module without a changelog", {
	plan 6;

	my IO::Path $module = App::Assixt::Commands::New.run(config => $config.clone.read: %(
		cwd => tempdir.IO,
		runtime => %(
			:no-changelog,
			name => "Local::Test::Module",
			author => %test-meta<author>,
			email => "6.d",
			perl => %test-meta<perl>,
			description => "Nondescript",
			license => %test-meta<license>,
			source-url => %test-meta<source-url>,
			auth => %test-meta<auth>,
		),
	));

	ok $module.d, "Module directory created";
	ok $module.add(".editorconfig").e, "Editorconfig created";
	ok $module.add(".gitignore").e, "Gitignore created";
	ok $module.add(".travis.yml").e, "Travis config created";
	ok $module.add(".gitlab-ci.yml").e, "GitLab CI config created";

	nok $module.add("CHANGELOG.md").e, "CHANGELOG missing";
};

# vim: ft=perl6 noet
