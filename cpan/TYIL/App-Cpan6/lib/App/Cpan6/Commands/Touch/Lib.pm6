#! /usr/bin/env false

use v6;

use App::Cpan6::Config;
use App::Cpan6::Meta;
use App::Cpan6::Template;

unit module App::Cpan6::Commands::Touch::Lib;

multi sub MAIN("touch", "lib", Str $provide, Str :$type = "") is export
{
	my $config = get-config;
	my %meta = get-meta;
	my $path = "./lib".IO;

	# Deduce the path to create
	for $provide.split("::") {
		$path = $path.add($_);
	}

	$path = $path.extension("pm6", parts => 0);

	if ($path.e) {
		die "File already exists at {$path.absolute}";
	}

	my $template = "module/";
	my %context = %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
		:$provide,
	);

	given $type {
		when "class" { $template ~= "class" }
		when "unit"  { $template ~= "unit" }
		default      { $template ~= "lib" }
	}

	template($template, $path, :%context);

	# Update META6.json
	%meta<provides>{$provide} = $path.relative;

	put-meta(:%meta);

	# Inform the user of success
	say "Added $provide to {%meta<name>}";
}

multi sub MAIN("touch", "class", Str $provide) is export
{
	MAIN("touch", "lib", $provide, type => "class");
}

multi sub MAIN("touch", "unit", Str $provide) is export
{
	MAIN("touch", "lib", $provide, type => "unit");
}
