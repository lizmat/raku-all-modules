#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;

unit module App::Assixt::Commands::Bootstrap::Config;

multi sub assixt(
	"bootstrap",
	"config",
	Str:D $option,
	Str:D $value,
	Config:D :$config,
) is export {
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

multi sub assixt(
	"bootstrap",
	"config",
	Str:D $option,
	Config:D :$config,
) is export {
	die "Invalid config option $option" unless $config{$option}:exists;

	given $config{$option} {
		when Bool { $config.set($option, confirm($option, $config.get($option, False))) }
		when Int  { $config.set($option, +ask($option, $config.get($option, 0)))        }
		when Str  { $config.set($option, ask($option, $config.get($option, "")))        }
	}

	say "$option = {$config{$option}}";
}

multi sub assixt(
	"bootstrap",
	"config",
	Config:D :$config,
) is export {
	for $config.keys -> $option {
		assixt(
			"bootstrap",
			"config",
			$option,
			:$config,
		);
	}
}

# vim: ft=perl6 noet
