#! /usr/bin/env false

use v6;

use App::Cpan6::Commands::Dist;
use App::Cpan6::Input;
use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Release;

multi sub MAIN("release", $path = ".", Bool :$ask = False) is export
{
	# Define release types
	my Str @release-types = (
		"Major",
		"Minor",
		"Bugfix",
	);
	my Int $default-release = 3;
	my Str $absolute-path = $path.IO.absolute;

	# Change to the directory to release
	chdir $absolute-path;

	# Make sure the directory is clean
	if ($absolute-path.IO.add(".git").e) {
		my $git-cmd = run « git status --short », :out;

		if (0 < $git-cmd.out.lines.elems) {
			die "Refusing to work on an unclean directory.";
		}
	}

	# Get the META6 info
	my %meta = get-meta;

	say "Making release for {%meta<name>} v{%meta<version>}";

	# Output the possible release types
	say "Release type";

	for @release-types.kv -> $i,  $type {
		say "  {$i + 1} - $type";
	};

	# Request user input to select the release type
	my Int $release;

	loop {
		my $input = ask("Release type", default => $default-release.Str);

		if ($input ~~ /^$ | ^\d+$/) {
			$release = $input.Int;
		}

		if ($release == 0) {
			$release = $default-release;
		}

		$release--;

		if ($release < @release-types.elems) {
			last;
		}
	}

	# Update the version accordingly
	my @version = %meta<version>.split(".");
	my @new-version = @version;

	given @release-types[$release].lc {
		when "major"  { 
			@new-version[0]++;
			@new-version[1] = 0;
			@new-version[2] = 0;
		}
		when "minor"  {
			@new-version[1]++;
			@new-version[2] = 0;
		}
		when "bugfix" {
			@new-version[2]++;
		}
	}

	%meta<version> = @new-version.join(".");

	say "New release version will be {%meta<version>}";

	exit if $ask && !confirm;

	put-meta(:%meta);

	# Commit the updated META6
	if ($absolute-path.IO.add(".git").e) {
		run « git add META6.json »;
		run « git commit -m "Bump version to {%meta<version>}" »;
		run « git tag "v{%meta<version>}" »;
	}

	return if $ask && !confirm("Create new dist?");

	# Build the dist
	MAIN("dist", $absolute-path, :force);
}
