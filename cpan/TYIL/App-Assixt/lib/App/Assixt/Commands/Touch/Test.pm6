#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

unit module App::Assixt::Commands::Touch::Test;

multi sub assixt(
	"touch",
	"test",
	Str $test,
	Config:D :$config,
) is export {
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
