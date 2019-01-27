#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

unit class App::Assixt::Commands::Touch::Class;

method run (
	Str:D $provide,
	Config:D :$config
) {
	my %meta = get-meta($config<cwd>);
	my $class = $config<cwd>.add("lib");

	$provide.split("::", :g).map({ $class.=add($_) });
	$class.=extension("pm6", :0parts);

	if ($class.e && !$config<force>) {
		err("touch.conflict", path => $class.absolute);

		return;
	}

	template("module/class", $class, clobber => $config<force>, context => %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
		author => %meta<authors>.join(", "),
		version => %meta<version>,
		:$provide,
	));

	# Update META6.json
	%meta<provides>{$provide} = $class.relative($config<cwd>);

	put-meta(%meta, $config<cwd>);

	# Inform the user of success
	out("touch", type => "class", file => $provide, module => %meta<name>);

	$class;
}

# vim: ft=perl6 noet
