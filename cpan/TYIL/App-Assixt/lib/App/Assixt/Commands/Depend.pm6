#! /usr/bin/env false

use v6.c;

use Config;
use Dist::Helper::Meta;

class App::Assixt::Commands::Depend
{
	multi method run(
		Str:D $module,
		Config :$config,
	) {
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

	multi method run(
		Str @modules,
		Config :$config,
	) {
		for @modules -> $module {
			self.run(
				"depend",
				$module,
				:$config
			);
		}
	}
}
