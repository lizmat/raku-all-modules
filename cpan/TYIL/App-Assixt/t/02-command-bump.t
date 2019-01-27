#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Bump;
use App::Assixt::Commands::Touch::Bin;
use App::Assixt::Commands::Touch::Class;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 4;

my IO::Path $module = create-test-module("Local::Test::Bump", tempdir.IO);
my Config $config = get-config(:!user-config).read: %(
	cwd => $module,
	:force,
);

App::Assixt::Commands::Touch::Bin.run("test-bin", :$config);
App::Assixt::Commands::Touch::Class.run("Local::Test::Bump::Test::Class", :$config);

subtest "Bump patch version", {
	plan 6;

	is get-meta($module)<version>, "0.0.0", "Version is now at 0.0.0";
	is get-meta($module)<api>, "0", "API is now at 0";

	App::Assixt::Commands::Bump.run("patch", :$config);

	is get-meta($module)<version>, "0.0.1", "Version is now at 0.0.1";
	is get-meta($module)<api>, "0", "API is still at 0";

	# This entails 2 additional tests
	for get-meta($module)<provides>.values -> $file {
		for $module.add($file).lines -> $line {
			next unless $line ~~ / \h* "=VERSION" \s+ (\S+) \s* /;

			is $0, "0.0.1", "Version in $file is now at 0.0.1";
		}
	};
};

subtest "Bump minor version", {
	plan 6;

	is get-meta($module)<version>, "0.0.1", "Version is now at 0.0.1";
	is get-meta($module)<api>, "0", "API is now at 0";

	App::Assixt::Commands::Bump.run("minor", :$config);

	is get-meta($module)<version>, "0.1.0", "Version is now at 0.1.0";
	is get-meta($module)<api>, "0", "API is still at 0";

	# This entails 2 additional tests
	for get-meta($module)<provides>.values -> $file {
		for $module.add($file).lines -> $line {
			next unless $line ~~ / \h* "=VERSION" \s+ (\S+) \s* /;

			is $0, "0.1.0", "Version in $file is now at 0.1.0";
		}
	};
};

subtest "Bump major version", {
	plan 6;

	is get-meta($module)<version>, "0.1.0", "Version is now at 0.1.0";
	is get-meta($module)<api>, "0", "API is now at 0";

	App::Assixt::Commands::Bump.run("major", :$config);

	is get-meta($module)<version>, "1.0.0", "Version is now at 1.0.0";
	is get-meta($module)<api>, "1", "API is now at 1";

	# This entails 2 additional tests
	for get-meta($module)<provides>.values -> $file {
		for $module.add($file).lines -> $line {
			next unless $line ~~ / \h* "=VERSION" \s+ (\S+) \s* /;

			is $0, "1.0.0", "Version in $file is now at 1.0.0";
		}
	};
};

subtest "Bump CHANGELOG versions", {
	plan 3;

	my Str $datestamp = Date.new(now).yyyy-mm-dd;
	my Config $config = get-config(:!user-config);

	subtest "Patch bump", {
		plan 2;

		$config<cwd> = create-test-module("Local::Test::Bump::Patch", tempdir.IO);
		App::Assixt::Commands::Bump.run("patch", :$config);

		for $config<cwd>.add("CHANGELOG.md").lines -> $line {
			next unless $line ~~ / ^ "## [" ( \S+ ) "] - " ( \S+ ) /;

			is $0, "0.0.1", "Version in CHANGELOG.md is now at 0.0.1";
			is $1, $datestamp, "Datestamp in CHANGELOG.md is correct";
		}
	}

	subtest "Minor bump", {
		plan 2;

		$config<cwd> = create-test-module("Local::Test::Bump::Minor", tempdir.IO);
		App::Assixt::Commands::Bump.run("minor", :$config);

		for $config<cwd>.add("CHANGELOG.md").lines -> $line {
			next unless $line ~~ / ^ "## [" ( \S+ ) "] - " ( \S+ ) /;

			is $0, "0.1.0", "Version in CHANGELOG.md is now at 0.1.0";
			is $1, $datestamp, "Datestamp in CHANGELOG.md is correct";
		}
	}

	subtest "Major bump", {
		plan 2;

		$config<cwd> = create-test-module("Local::Test::Bump::Major", tempdir.IO);
		App::Assixt::Commands::Bump.run("major", :$config);

		for $config<cwd>.add("CHANGELOG.md").lines -> $line {
			next unless $line ~~ / ^ "## [" ( \S+ ) "] - " ( \S+ ) /;

			is $0, "1.0.0", "Version in CHANGELOG.md is now at 1.0.0";
			is $1, $datestamp, "Datestamp in CHANGELOG.md is correct";
		}
	}
}

# vim: ft=perl6 noet
