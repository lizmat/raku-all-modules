#! /usr/bin/env false

use v6;

use App::Cpan6::Commands::Dist;
use App::Cpan6::Input;
use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Bump;

multi sub MAIN("bump", Str $path, Bool :$ask = False) is export
{
	# Define bump types
	my Str @bump-types = (
		"Major",
		"Minor",
		"Bugfix",
	);
	my Int $default-bump = 3;

	# Change to the directory to bump
	chdir $path;

	# Make sure the directory is clean
	if ($path.IO.add(".git").e) {
		my $git-cmd = run « git status --short », :out;

		if (0 < $git-cmd.out.lines.elems) {
			die "Refusing to work on an unclean directory.";
		}
	}

	# Get the META6 info
	my %meta = get-meta;

	# Output the possible bump types
	say "Bump parts";

	for @bump-types.kv -> $i,  $type {
		say "  {$i + 1} - $type";
	};

	# Request user input to select the bump type
	my Int $bump;

	loop {
		my $input = ask("Bump part", default => $default-bump.Str);

		if ($input ~~ /^$ | ^\d+$/) {
			$bump = $input.Int;
		}

		if ($bump == 0) {
			$bump = $default-bump;
		}

		$bump--;

		if ($bump < @bump-types.elems) {
			last;
		}
	}

	# Update the version accordingly
	my @version = %meta<version>.split(".");
	my @new-version = @version;

	given @bump-types[$bump].lc {
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

	say "Bumping {%meta<name>} to {%meta<version>}";

	exit if $ask && !confirm;

	put-meta(:%meta);

	# Commit the updated META6
	if ($path.IO.add(".git").e) {
		run « git add META6.json »;
		run « git commit -m "Bump version to {%meta<version>}" »;
		run « git tag "v{%meta<version>}" »;
	}

	return if $ask && !confirm("Create new dist?");

	# Build the dist
	MAIN("dist", $path, :force);
}

multi sub MAIN("bump", Bool :$ask = False) is export
{
	MAIN("bump", ".", :$ask);
}

multi sub MAIN("bump", *@paths, Bool :$ask = False) is export
{
	for @paths -> $path {
		MAIN("bump", $path.IO.absolute, :$ask);
	}
}
