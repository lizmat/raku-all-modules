#! /usr/bin/env false

use v6.c;

use App::Assixt::Commands::Dist;
use App::Assixt::Input;
use Dist::Helper::Meta;
use SemVer;

unit module App::Assixt::Commands::Bump;

my Str @bump-types = (
	"major",
	"minor",
	"patch",
);

multi sub MAIN(
	"bump",
	Str:D $type,
	Bool:D :$force = False,
	Bool:D :$no-user-config = False,
) is export {
	die "Illegal bump type supplied: $type" unless @bump-types ∋ $type.lc;

	my %meta = get-meta;

	# Update the version accordingly
	my SemVer $version .= new(%meta<version>);

	given $type.lc {
		when "major" { $version.bump-major }
		when "minor" { $version.bump-minor }
		when "patch" { $version.bump-patch }
	}

	%meta<version> = ~$version;

	put-meta(:%meta);

	say "{%meta<name>} bumped to to {%meta<version>}";
}

multi sub MAIN(
	"bump",
	Bool:D :$force = False,
	Bool:D :$no-user-config = False,
) is export {
	my Int $default-bump = 3;

	# Output the possible bump types
	say "Bump parts";

	for @bump-types.kv -> $i,  $type {
		say "  {$i + 1} - $type";
	};

	# Request user input to select the bump type
	my Int $bump;

	loop {
		my $input = ask("Bump part", ~$default-bump.tc);

		$bump = $input.Int if $input ~~ /^$ | ^\d+$/;
		$bump = $default-bump if $bump == 0;

		$bump--;

		last if $bump < @bump-types.elems;
	}

	MAIN("bump", @bump-types[$bump], :$force, :$no-user-config);
}
