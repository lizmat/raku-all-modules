#! /usr/bin/env false

use v6;

use App::Cpan6;
use App::Cpan6::Meta;
use App::Cpan6::Package::Ebuild;

unit module App::Cpan6::Commands::Pkg::Ebuild;

multi sub MAIN("pkg", "ebuild", $path where /META6.json$/, Bool :$force = False) is export
{
	my %meta = get-meta;
	my Str $output = make-ebuild(%meta);
	my Str $atom-name = atom-name(%meta<name>, %meta<version>);

	spurt("{$atom-name}.ebuild", $output);

	say "Saved $atom-name";
}
