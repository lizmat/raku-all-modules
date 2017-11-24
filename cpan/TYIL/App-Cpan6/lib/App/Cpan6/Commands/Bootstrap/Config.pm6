#! /usr/bin/env false

use v6.c;

use App::Cpan6::Config;
use App::Cpan6::Input;
use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Bootstrap::Config;

multi sub MAIN("bootstrap", "config", Str:D $option) is export
{
	my $config = get-config;

	die "Invalid config option $option" unless $config{$option}:exists;

	given $config{$option} {
		when Bool { $config.set($option, confirm($option, $config.get($option, False))) }
		when Int  { $config.set($option, +ask($option, $config.get($option, 0)))        }
		when Str  { $config.set($option, ask($option, $config.get($option, "")))        }
	}

	put-config(:$config);
}

multi sub MAIN("bootstrap", "config") is export
{
	for get-config.keys -> $option {
		MAIN("bootstrap", "config", $option);
	}
}

# vim: ft=perl6 noet
