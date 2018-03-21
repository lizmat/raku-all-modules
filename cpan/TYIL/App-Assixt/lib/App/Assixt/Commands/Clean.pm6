#! /usr/bin/env false

use v6.c;

use Config;
use App::Assixt::Input;
use Dist::Helper::Clean;
use Dist::Helper::Meta;

unit module App::Assixt::Commands::Clean;

multi sub assixt(
	"clean",
	Str:D $path = ".",
	Config:D :$config,
) is export {
	# Clean up the META6.json
	unless ($config<runtime><no-meta>) {
		my %meta = clean-meta(
			:$path,
			force => $config<force>,
			verbose => $config<verbose>,
		);

		put-meta(:%meta, :$path) if $config<force> || confirm("Save cleaned META6.json?");
	}

	# Clean up unreferenced files
	unless ($config<runtime><no-files>) {
		my @orphans = clean-files(
			:$path,
			force => $config<force>,
			verbose => $config<verbose>,
		);

		for @orphans -> $orphan {
			unlink($orphan) if $config<force> || confirm("Really delete $orphan?");
		}
	}

	True;
}

# vim: ft=perl6 noet
