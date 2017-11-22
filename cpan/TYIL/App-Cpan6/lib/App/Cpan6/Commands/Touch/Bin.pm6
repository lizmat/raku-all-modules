#! /usr/bin/env false

use v6;

use App::Cpan6::Config;
use App::Cpan6::Meta;
use App::Cpan6::Template;

unit module App::Cpan6::Commands::Touch::Bin;

multi sub MAIN("touch", "bin", Str $provide) is export
{
	my $config = get-config;
	my %meta = get-meta;
	my $path = "./bin".IO;

	$path = $path.add($provide);

	if ($path.e) {
		die "File already exists at {$path.absolute}";
	}

	my %context = %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
		:$provide,
	);

	mkdir $path.parent.absolute;

	template("module/bin", $path.absolute, :%context);

	# Update META6.json
	%meta<provides>{$provide} = $path.relative;

	put-meta(:%meta);

	# Inform the user of success
	say "Added $provide to {%meta<name>}";
}
