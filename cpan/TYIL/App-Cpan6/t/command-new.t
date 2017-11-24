#! /usr/bin/env perl6

use v6.c;

use App::Cpan6::Config;
use App::Cpan6::Meta;
use App::Cpan6::Commands::New;
use Test;
use File::Temp;

plan 4;

multi sub MAIN { 0 } # Solves error code 2 from running the test itself

my $root = tempdir;
my %test-meta = %(
	author => "Patrick Spek",
	description => "Just another test module",
	email => "p.spek@tyil.work",
	license => "GPL-3.0",
	perl => "6.c",
	meta-version => 0
);

my $config = get-config(:no-user-config);

subtest "Create a new module", {
	plan 6;

	chdir $root;

	ok MAIN(
		"new",
		name => "Local::Test::Module",
		author => %test-meta<author>,
		email => %test-meta<email>,
		perl => "c",
		description => %test-meta<description>,
		license => %test-meta<license>,
		no-user-config => True,
	), "cpan6 new";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-Module";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.git".IO.d, "Git initialized";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";

	subtest "Verify META6.json", {
		plan 10;

		my %meta = get-meta;

		is %meta<meta-version>, %test-meta<meta-version>, "meta-version is correct";
		is %meta<perl>, %test-meta<perl>, "perl is correct";
		is %meta<name>, "Local::Test::Module", "name is correct";
		is %meta<description>, %test-meta<description>, "description is correct";
		is %meta<license>, %test-meta<license>, "license is correct";
		is %meta<version>, "0.0.0", "version is correct";
		is %meta<authors>, "{%test-meta<author>} <{%test-meta<email>}>", "author is correct";
		is %meta<resources>.elems, 0, "resources is empty";
		is %meta<provides>.elems, 0, "provides is empty";
		is %meta<depends>.elems, 0, "depends is empty";
	}
};

subtest "Create a new module with force", {
	plan 6;

	chdir $root;

	ok MAIN(
		"new",
		name => "Local::Test::Module",
		author => %test-meta<author>,
		email => %test-meta<email>,
		perl => "d",
		description => "Nondescript",
		license => %test-meta<license>,
		force => True,
		no-user-config => True,
	), "cpan6 new";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-Module";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.git".IO.d, "Git initialized";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";

	subtest "Verify META6.json", {
		plan 10;

		my %meta = get-meta;

		is %meta<meta-version>, %test-meta<meta-version>, "meta-version is correct";
		is %meta<perl>, "6.d", "perl is correct";
		is %meta<name>, "Local::Test::Module", "name is correct";
		is %meta<description>, "Nondescript", "description is correct";
		is %meta<license>, %test-meta<license>, "license is correct";
		is %meta<version>, "0.0.0", "version is correct";
		is %meta<authors>, "{%test-meta<author>} <{%test-meta<email>}>", "author is correct";
		is %meta<resources>.elems, 0, "resources is empty";
		is %meta<provides>.elems, 0, "provides is empty";
		is %meta<depends>.elems, 0, "depends is empty";
	}
};

subtest "Create a new module without git info", {
	plan 5;

	chdir $root;

	ok MAIN(
		"new",
		name => "Local::Test::NoGitModule",
		author => %test-meta<author>,
		email => %test-meta<email>,
		perl => "c",
		description => %test-meta<description>,
		license => %test-meta<license>,
		no-git => True,
		no-user-config => True,
	), "cpan6 new";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-NoGitModule";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";

	nok "$module-root/.git".IO.d, "Git missing";
};

subtest "Create a new module without travis info", {
	plan 5;

	chdir $root;

	ok MAIN(
		"new",
		name => "Local::Test::NoTravisModule",
		author => %test-meta<author>,
		email => %test-meta<email>,
		perl => "c",
		description => %test-meta<description>,
		license => %test-meta<license>,
		no-travis => True,
		no-user-config => True,
	), "cpan6 new";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-NoTravisModule";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.git".IO.d, "Git initialized";

	nok "$module-root/.travis.yml".IO.e, "Travis config missing";
};

# vim: ft=perl6 noet
