#! /usr/bin/env false

use v6.c;

use App::Cpan6::Config;
use App::Cpan6::Input;
use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Bootstrap::Config;

my %options = %(
	"cpan6.distdir" => "str",
	"new-module.author" => "str",
	"new-module.email" => "str",
	"new-module.perl" => "str",
	"new-module.license" => "str",
	"new-module.dir-prefix" => "str",
	"external.git" => "bool",
	"external.travis" => "bool",
	"style.indent" => "str",
	"style.spaces" => "int",
	"pause.id" => "str",
);

multi sub MAIN("bootstrap", "config", Str:D $option) is export
{
	die "Invalid config option $option" unless %options{$option}:exists;

	my $config = get-config;

	given %options{$option} {
		when "bool" { $config.set($option, confirm($option, $config.get($option, False))) }
		when "str"  { $config.set($option, ask($option, $config.get($option, "")))        }
		when "int"  { $config.set($option, +ask($option, $config.get($option, 0)))        }
	}

	put-config(:$config);
}

multi sub MAIN("bootstrap", "config") is export
{
	for %options.options.sort -> $option {
		MAIN("bootstrap", "config", $option);
	}
}

# vim: ft=perl6 noet
