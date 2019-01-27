#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

unit class App::Assixt::Commands::Touch::Test;

method run (
	Str:D $test,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>);
	my $path = $config<cwd>.add("t").add($test).extension("t", :0parts);

	if ($path.e && !$config<force>) {
		err("touch.conflict", path => $path.absolute);

		return;
	}

	my %context = %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
	);

	template("module/test", $path, :%context);

	# Inform the user of success
	out("touch", type => "test", file => $path.basename, module => %meta<name>);

	$path;
}
