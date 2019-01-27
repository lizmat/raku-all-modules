#! /usr/bin/env false

use v6.c;

use Config;
use Dist::Helper::Meta;
use Zef::Distribution::DependencySpecification;

unit class App::Assixt::Commands::Undepend;

multi method run(
	Str:D $module,
	Config:D :$config!,
) {
	# Get the meta info
	my %meta = get-meta($config<cwd>);
	my @depends = [];

	# Remove the dependency if it exists
	my Zef::Distribution::DependencySpecification $spec .= new($module);

	for %meta<depends>.list {
		my Zef::Distribution::DependencySpecification $dep-spec .= new($_);

		next if $dep-spec.spec-matcher($spec);

		@depends.push: $_;
	}

	%meta<depends> = @depends;

	# Write the new META6.json
	put-meta(%meta, $config<cwd>);

	# And finish off with some user friendly feedback
	say "$module has been removed as a dependency from {%meta<name>}";
}

multi method run(
	*@modules,
	Config:D :$config!,
) {
	samewith($_, :$config) for @modules;
}

=begin pod

=NAME    App::Assixt::Commands::Undepend
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt undepend <module>

=head1 Description

Remove a dependency from a module.

=head1 Examples

    assixt undepend Hash::Merge

=head1 SEE ALSO

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Depend>

=end pod

# vim: ft=perl6 noet
