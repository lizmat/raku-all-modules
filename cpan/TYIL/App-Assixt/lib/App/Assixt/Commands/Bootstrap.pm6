#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;

unit class App::Assixt::Commands::Bootstrap;

method run(
	*@args,
	Config:D :$config
) {
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

=begin pod

=NAME    App::Assixt::Commands::Bootstrap
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt bootstrap <target>

=head2 Targets

=defn config
Walk through all configuration options, and save the updated configuration to
the configuration file.

You can find an overview of all available configuration options with their
descriptions in the documentation of C<App::Assixt::Config>.

=head1 Description

Bootstrapping functionality for C<App::Assixt>. Currently, there's only one
bootstrap command, L<C<config>|App::Assixt::Commands::Bootstrap::Config>.

=head1 Examples

    assixt bootstrap config

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Bootstrap::Config>

=end pod

# vim: ft=perl6 noet
