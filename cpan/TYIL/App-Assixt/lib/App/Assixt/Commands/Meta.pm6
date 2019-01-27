#! /usr/bin/env false

use v6.c;

use App::Assixt::Input;
use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;

unit class App::Assixt::Commands::Meta;

multi method run (
	*@args ($, *@),
	Config:D :$config,
) {
	return self.run-simple(|@args, :$config) if @args[0] ∈ <
		auth
		description
		license
		source-url
	>;

	my $type = @args.shift;
	my $formatted-type = $type.split("-", :g)».tclc.join();
	my $lib = "{$?CLASS.^name}::$formatted-type";

	err("debug.require", module => $lib, intent => $type) if $config<verbose>;

	try require ::($lib);

	if (::($lib) ~~ Failure) {
		err("error.subcommand", command => $type, docs => $?CLASS.^name);

		note ::($lib).Str if $config<verbose>;

		return;
	}

	::($lib).run(|@args, :$config);
}

multi method run (
	Config:D :$config,
) {
	err("error.subcommand.missing", command => "meta", docs => $?CLASS.^name);
}

multi method run-simple (
	Str:D $type,
	Str:D $value,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>.absolute);

	%meta{$type} = $value;

	put-meta(:%meta, path => $config<cwd>.absolute);
}

multi method run-simple (
	Str:D $type,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>.absolute);

	samewith(ask($type, %meta{$type} // ""), :$config);
}

=begin pod

=NAME    App::Assixt::Commands::Meta
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt meta <subcommand> <value>

=head2 Subcommands

=defn source-url
Set the module's C<source-url> attribute. This indicates where an end-user will
be able to find the unaltered source code of the module.

=head1 Description

Change a meta attribute of the module, which is stored in the C<META6.json>
file.

=head1 Examples

    assixt meta source-url https://gitlab.com/tyil/perl6-app-assixt

=head1 See also

=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
