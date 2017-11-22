#! /usr/bin/env false

use v6;

use App::Cpan6::Config;
use App::Cpan6::Meta;
use App::Cpan6::Template;

unit module App::Cpan6::Commands::Touch::Test;

multi sub MAIN("touch", "test", Str $test) is export
{
	my $config = get-config;
	my %meta = get-meta;
	my $path = "./t".IO;

	$path = $path.add($test);
	$path = $path.extension("t", parts => 0);

	if ($path.e) {
		die "File already exists at {$path.absolute}";
	}

	my %context = %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
	);

	template("module/test", $path, :%context);

	# Inform the user of success
	say "Added test $test to {%meta<name>}";
}
