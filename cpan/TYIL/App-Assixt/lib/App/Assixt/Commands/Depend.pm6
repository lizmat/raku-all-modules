#! /usr/bin/env false

use v6.c;

use Config;
use Dist::Helper::Meta;

unit module App::Assixt::Commands::Depend;

multi sub assixt(
	"depend",
	Str:D $module,
	Config :$config,
) is export {
	# Get the meta info
	my %meta = get-meta;

	# Install the new dependency with zef
	unless ($config<runtime><no-install>) {
		my $zef = run « zef --cpan install "$module" »;

		die "Zef failed, bailing" if 0 < $zef.exitcode;
	}

	# Add the new dependency if its not listed yet
	if (%meta<depends> ∌ $module) {
		%meta<depends>.push: $module;
	}

	# Write the new META6.json
	put-meta(:%meta);

	# And finish off with some user friendly feedback
	say "$module has been added as a dependency to {%meta<name>}";
}

multi sub assixt(
	"depend",
	Str @modules,
	Config :$config,
) is export {
	for @modules -> $module {
		assixt(
			"depend",
			$module,
			:$config
		);
	}
}
