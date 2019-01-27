#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;

unit class App::Assixt::Commands::Depend;

multi method run (
	Str:D $module,
	Config:D :$config!,
) {
	# Get the meta info
	my %meta = get-meta($config<cwd>);

	# Install the new dependency with zef
	if (!$config<runtime><no-install>) {
		my $zef = run « zef --cpan install "$module" »;

		if (0 < $zef.exitcode) {
			err("depend.zef", :$module);

			return;
		}
	}

	# Add the new dependency if its not listed yet
	%meta<depends>.push: $module if %meta<depends> ∌ $module;

	# Write the new META6.json
	put-meta(%meta, $config<cwd>);

	# And finish off with some user friendly feedback
	out("depend", dependency => $module, module => %meta<name>);
}

multi method run (
	*@modules,
	Config:D :$config!,
) {
	samewith($_, :$config) for @modules;
}

=begin pod

=NAME    App::Assixt::Commands::Depend
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt depend <module>

=head1 Description

Add a dependency to a given module. This will add it to the C<dependencies> key
in C<META6.json>. Unless the C<--no-zef> option has been passed, it will also
install the module using C<zef> on the local machine.

=head1 Examples

    assixt depend Config
    assixt depend Pod::To::Pager --no-zef

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Undepend>
=item1 C<zef>
=item1 L<Perl 6 module directory|https://modules.perl6.org>

=end pod

# vim: ft=perl6 noet
