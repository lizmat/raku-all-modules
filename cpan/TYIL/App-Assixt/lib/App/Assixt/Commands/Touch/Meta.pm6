#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

#| Touch meta files. These are files that are related to the module's source
#| code, but not necessarily part of the module in order to use it. Examples of
#| this would include CI configuration files. This can be used to add back
#| default templates that were either removed, or added in C<App::Assixt> after
#| a module was created.
unit class App::Assixt::Commands::Touch::Meta;

multi method run (
	Str:D $type,
	Config:D :$config,
) {
	my %files =
		changelog => "changelog.md",
		editorconfig => "editorconfig",
		gitignore => "gitignore",
		gitlab => "gitlab-ci.yml",
		gitlab-ci => "gitlab-ci.yml",
		readme => "readme.pod6",
		travis => "travis.yml",
		travis-ci => "travis.yml",
	;

	my Str $template = %files{$type};

	if (!$template) {
		err("touch.meta", type => $type, docs => $?CLASS.^name);

		return
	}

	my IO::Path $output = $config<cwd>.add(self.template-location($template));

	if ($output.e && !$config<force>) {
		err("touch.conflict", path => $output.absolute);

		return;
	}

	my %meta = get-meta($config<cwd>);

	template($template, $output, clobber => $config<force>, context => %(
		name => %meta<name>,
		author => %meta<authors>.join(", "),
		version => %meta<version>,
		description => %meta<description>,
		indent => $config<style><indent>,
		spaces => $config<style><spaces>,
		directory => $config<cwd>.basename,
		license => %meta<license>,
	));

	out("touch", type => "meta template", file => $output.basename, module => %meta<name>);

	$output;
}

method template-location (
	Str:D $template,
	--> Str
) is export {
	given $template {
		when "changelog.md"  { return "CHANGELOG.md" }
		when "editorconfig"  { return ".$template"   }
		when "gitignore"     { return ".$template"   }
		when "gitlab-ci.yml" { return ".$template"   }
		when "readme.pod6"   { return "README.pod6"  }
		default              { return $template      }
	}
}

=begin pod

=NAME    App::Assixt::Commands::Touch::Meta
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt touch meta <type>

=head2 Types

=defn changelog
Create a new C<CHANGELOG.md> file in the project root. This file adheres to the
L<Keep a Changelog|https://keepachangelog.com/en/1.0.0> specification.

=defn editorconfig
Create a new C<.editorconfig> file, based on your style configuration.

=defn gitignore
Create a new C<.gitignore> file. This gitignore file contains some standard
ignore rules to keep unwanted files out of the repository, most notably, the
C<.precomp> files.

=defn gitlab-ci
Create a new C<.gitlab-ci.pml> file, containing a base configuration to
automatically test your module with GitLab CI.

Alternative names: I<gitlab>.

=defn readme
Create a new C<README.pod6> file. This will contain some default information,
but will require manual effort to become a good readme file.

=defn travis-ci
Create a new C<.travis.yml> file, containing a base configuration to
automatically test your module with Travis CI.

Alternative names: I<travis>.

=head1 Description

Create various files containing meta information on the module.

=head1 See also

C<assixt>

=end pod

# vim: ft=perl6 noet
