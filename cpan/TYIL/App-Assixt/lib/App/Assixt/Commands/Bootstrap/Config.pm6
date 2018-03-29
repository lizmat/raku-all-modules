#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;

class App::Assixt::Commands::Bootstrap::Config
{
	multi method run(
		"config",
		Str:D $option,
		Str:D $value,
		Config:D :$config,
	) {
		die "Invalid config option $option" unless $config{$option}:exists;

		given $config{$option} {
			when Bool { $config.set($option, $value.starts-with('y')) }
			when Int  { $config.set($option, +$value)                 }
			when Str  { $config.set($option, ~$value)                 }
		}

		if (!$config<force>) {
			say "$option = {$config{$option}}";
			exit unless confirm("Save?");
		}

		put-config(:$config, path => $config<runtime><config-file> // "");

		say "Configuration updated";
	}

	multi method run(
		"config",
		Str:D $option,
		Config:D :$config,
	) {
		die "Invalid config option $option" unless $config{$option}:exists;

		given $config{$option} {
			when Bool { $config.set($option, confirm($option, $config.get($option, False))) }
			when Int  { $config.set($option, +ask($option, $config.get($option, 0)))        }
			when Str  { $config.set($option, ask($option, $config.get($option, "")))        }
		}

		say "$option = {$config{$option}}";
	}

	multi method run(
		"config",
		Config:D :$config,
	) {
		for $config.keys -> $option {
			self.run(
				"config",
				$option,
				:$config,
			);
		}
	}
}

# vim: ft=perl6 noet
