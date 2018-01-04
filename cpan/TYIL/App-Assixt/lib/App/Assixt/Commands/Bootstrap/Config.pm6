#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Dist::Helper::Meta;

unit module App::Assixt::Commands::Bootstrap::Config;

multi sub MAIN(
	"bootstrap",
	"config",
	Str:D $option,
	Str:D $value,
	:$config-file,
	Bool:D :$force = False,
) is export {
	my $config = get-config(:$config-file);

	die "Invalid config option $option" unless $config{$option}:exists;

	given $config{$option} {
		when Bool { $config.set($option, $value.starts-with('y')) }
		when Int  { $config.set($option, +$value)                 }
		when Str  { $config.set($option, ~$value)                 }
	}

	if (!$force) {
		say "$option = {$config{$option}}";
		exit unless confirm("Save?");
	}

	put-config(:$config, path => $config-file // "");

	say "Configuration updated";
}

multi sub MAIN(
	"bootstrap",
	"config",
	Str:D $option,
	:@config-file,
) is export {
	my $config = get-config(:@config-file);

	die "Invalid config option $option" unless $config{$option}:exists;

	given $config{$option} {
		when Bool { $config.set($option, confirm($option, $config.get($option, False))) }
		when Int  { $config.set($option, +ask($option, $config.get($option, 0)))        }
		when Str  { $config.set($option, ask($option, $config.get($option, "")))        }
	}

	put-config(:$config);
}

multi sub MAIN(
	"bootstrap",
	"config",
	:@config-file,
) is export {
	for get-config.keys -> $option {
		MAIN("bootstrap", "config", $option, :@config-file);
	}
}

# vim: ft=perl6 noet
