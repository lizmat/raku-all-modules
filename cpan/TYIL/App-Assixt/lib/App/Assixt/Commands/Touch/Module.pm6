#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

unit class App::Assixt::Commands::Touch::Module;

method run (
	Str:D $provide,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>);
	my $lib = $config<cwd>.add("lib");

	$provide.split("::", :g).map({ $lib.=add($_) });
	$lib.=extension("pm6", :0parts);

	if ($lib.e && !$config<force>) {
		err("touch.conflict", path => $lib.absolute);

		return;
	}

	template("module/module", $lib, clobber => $config<force>, context => %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
		author => %meta<authors>.join(", "),
		version => %meta<version>,
		:$provide,
	));

	# Update META6.json
	%meta<provides>{$provide} = $lib.relative($config<cwd>);

	put-meta(%meta, $config<cwd>);

	# Inform the user of success
	out("touch", type => "module", file => $provide, module => %meta<name>);

	$lib;
}

# vim: ft=perl6 noet
