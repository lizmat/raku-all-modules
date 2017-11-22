#! /usr/bin/env false

use v6;

use App::Cpan6::Commands::Dist;
use App::Cpan6::Config;
use App::Cpan6::Input;
use App::Cpan6::Meta;
use File::Which;
use SemVer;

unit module App::Cpan6::Commands::Bump;

my Str @bump-types = (
	"major",
	"minor",
	"patch",
);

multi sub MAIN("bump", Str:D $type, Bool:D :$force = False) is export
{
	die "Illegal bump type supplied: $type" unless @bump-types ∋ $type.lc;

	my $config = get-config;
	my %meta = get-meta;

	# Make sure the directory is clean
	if ($config<external><git> && ".git".IO.e && which("git")) {
		my $git-cmd = run « git status --short », :out;

		if (0 < $git-cmd.out.lines.elems && !$force) {
			die "Refusing to work on an unclean directory.";
		}
	}

	# Update the version accordingly
	my SemVer $version .= new(%meta<version>);

	given $type.lc {
		when "major" { $version.bump-major }
		when "minor" { $version.bump-minor }
		when "patch" { $version.bump-patch }
	}

	%meta<version> = ~$version;

	put-meta(:%meta);

	# Commit the updated META6
	if ($config<external><git> && ".git".IO.e && which("git")) {
		run « git add META6.json »;
		run « git commit -m "Bump version to {%meta<version>}" »;
		run « git tag "v{%meta<version>}" »;
	}

	say "{%meta<name>} bumped to to {%meta<version>}";
}

multi sub MAIN("bump", Bool:D :$force = False) is export
{
	my Int $default-bump = 3;

	# Output the possible bump types
	say "Bump parts";

	for @bump-types.kv -> $i,  $type {
		say "  {$i + 1} - $type";
	};

	# Request user input to select the bump type
	my Int $bump;

	loop {
		my $input = ask("Bump part", default => ~$default-bump.tc);

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

	MAIN("bump", @bump-types[$bump], :$force);
}
