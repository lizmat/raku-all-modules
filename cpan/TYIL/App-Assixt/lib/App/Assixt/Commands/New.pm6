#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;
use File::Directory::Tree;
use File::Which;
use Hash::Merge;

unit class App::Assixt::Commands::New;

multi method run (
	Config:D :$config,
) {
	$config<runtime><name> //= ask("Module name");

	my IO::Path $dir = $config<runtime><cwd>
		?? $config<runtime><cwd>.IO
		!! $config<cwd>
		;

	# Make sure the directory path isn't already in use
	CHECKPATH: loop {
		# Get the full path
		$dir .= add($config.get("new-module.dir-prefix") ~ $config<runtime><name>.subst("::", "-", :g));

		# No need to check anything if --force is supplied
		last if $config<force>;

		# Make sure it isn't already taken on the local system
		if ($dir.e) {
			err("new.conflict", directory => $dir.absolute);

			$config<runtime><name> = ask("Module name", $config<runtime><name>);

			redo CHECKPATH;
		}

		# If we can reach this, it should be all right
		last;
	}

	$config<runtime><author> //= ask("Your name", $config.get("new-module.author"));
	$config<runtime><email> //= ask("Your email address", $config.get("new-module.email"));
	$config<runtime><perl> //= ask("Perl 6 version", $config.get("new-module.perl"));
	$config<runtime><description> //= ask("Module description", "Nondescript");
	$config<runtime><license> //= ask("License key", $config.get("new-module.license"));
	$config<runtime><source-url> //= ask("Source URL (optional)", :empty);
	$config<runtime><auth> //= ask("Auth key (optional)", $config.get("new-module.auth"), :empty);

	# Create the initial %meta
	my %meta = merge-hash(new-meta, %(
		api => "0",
		version => "0.0.0",
		perl => "6.$config<runtime><perl>",
		name => $config<runtime><name>,
		description => $config<runtime><description>,
		license => $config<runtime><license>,
		authors => [
			"$config<runtime><author> <$config<runtime><email>>",
		],
		source-url => $config<runtime><source-url>,
		auth => $config<runtime><auth>,
	));

	# Create the module skeleton
	mkdir $dir unless $dir.d;
	mkdir $dir.add("bin") unless $config<force> && "bin".IO.d;
	mkdir $dir.add("lib") unless $config<force> && "lib".IO.d;
	mkdir $dir.add("resources") unless $config<force> && "resources".IO.d;
	mkdir $dir.add("t") unless $config<force> && "t".IO.d;

	template("readme.pod6", $dir.add("README.pod6"), clobber => $config<force>, context => %(
		name => %meta<name>,
		author => %meta<authors>.join(", "),
		version => ~%meta<version>,
		description => %meta<description>,
		license => %meta<license>,
	));

	template("editorconfig", $dir.add(".editorconfig"), context => $config<style>, clobber => $config<force>);
	template("gitignore", $dir.add(".gitignore"), clobber => $config<force>) if $config<external><git> && !$config<runtime><no-git>;
	template("travis.yml", $dir.add(".travis.yml"), clobber => $config<force>) if $config<external><travis> && !$config<runtime><no-travis>;
	template("changelog.md", $dir.add("CHANGELOG.md"), clobber => $config<force>) if !$config<runtime><no-changelog>;

	if ($config<external><gitlab-ci> && !$config<runtime><no-gitlab-ci>) {
		my %context =
			name => $config<runtime><name>,
			directory => $dir,
		;

		template("gitlab-ci.yml", $dir.add(".gitlab-ci.yml"), :%context, clobber => $config<force>);
	}

	# Write some files
	put-meta(:%meta, path => $dir);

	out("new", path => $dir.absolute, module => %meta<name>);

	$dir;
}

multi method run (
	Str:D $name,
	Config:D :$config,
) {
	$config<runtime><name> = $name;

	samewith(:$config);
}

=begin pod

=NAME    App::Assixt::Commands::New
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt new [name] [defaults]

=head2 Defaults

=defn [--name=Str]

The name of the module. If not specified, it will be prompted.

=defn [--author=Str]

The author's name. If not specified, it will be prompted. The default value can
be set using the C<new-module.author> configuration key.

=defn [--email=Str]

The author's email address. If not specified, it will be prompted. The default
value can be set using the C<new-module.email> configuration key.

=defn [--perl=Str]

The Perl 6 version to use throughout the module. If not specified, it will be
prompted. The default value is C<"c">, but can be canfigured using the
C<new-module.perl> configuration key.

=defn [--license=Str]

The software license to use for the module. If not specified, it will be
prompted. The default license is
L<C<"AGPL-3.0>|https://www.gnu.org/licenses/agpl-3.0.nl.html>, but can be
configured using the C<new-module.license> configuration key.

=head1 Description

Create a distribution tarball of a module. The resulting tarball will be saved
in the location specified by the C<assixt.distdir> configuration key.
Optionally, C<--output-dir> can be given a path to store the distribution in,
which will take precedence over the C<assixt.distdir> value.

=head1 Examples

    assixt new
    assixt new --name=Local::Test

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Config>

=end pod

# vim: ft=perl6 noet
