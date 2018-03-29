#! /usr/bin/env false

use v6.c;

use Config;
use App::Assixt::Input;
use Dist::Helper::Meta;
use SemVer;

my Str @bump-types = (
	"major",
	"minor",
	"patch",
);

class App::Assixt::Commands::Bump
{
	multi method run(
		Str:D $type,
		Config:D :$config,
	) {
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

	multi method run(
		Config:D :$config,
	) {
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

		self.run(@bump-types[$bump], :$config);
	}
}
