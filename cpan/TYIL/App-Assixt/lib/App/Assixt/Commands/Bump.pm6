#! /usr/bin/env false

use v6.c;

use App::Assixt::Input;
use App::Assixt::Output;
use Config;
use Dist::Helper::Meta;
use Version::Semantic;

my Str @bump-levels = (
	"major",
	"minor",
	"patch",
);

unit class App::Assixt::Commands::Bump;

multi method run (
	Str:D $level,
	Config:D :$config,
) {
	if (@bump-levels ∌ $level.lc) {
		err("error.bump-level", :$level);

		return;
	}

	my %meta = get-meta($config<cwd>);
	my Str $version-string = %meta<version>;

	# Set a starting semantic version number to work with
	$version-string = "0.0.0" if $version-string eq "*";

	my Version::Semantic $version .= new(%meta<version>);

	given $level.lc {
		when "major" { $version.bump-major }
		when "minor" { $version.bump-minor }
		when "patch" { $version.bump-patch }
	}

	%meta<version> = ~$version;
	%meta<api> = ~$version.parts[0];

	put-meta(%meta, $config<cwd>);

	# Bump other files
	self!bump-provides($config, ~$version, %meta<provides>.values);
	self!bump-changelog($config, ~$version);

	out("bump", module => %meta<name>, version => %meta<version>);

	%meta<version>;
}

multi method run (
	Config:D :$config,
) {
	my Int $default-level = 3;

	# Output the possible bump level
	say "Bump levels";

	for @bump-levels.kv -> $i,  $level {
		say "  {$i + 1} - $level";
	};

	# Request user input to select the bump level
	my Int $level;

	loop {
		my $input = ask("Bump part", ~$default-level.tc);

		$level = $input.Int if $input ~~ /^$ | ^\d+$/;
		$level = $default-level if $level == 0;

		$level--;

		last if $level < @bump-levels.elems;
	}

	self.run(@bump-levels[$level], :$config);
}

#| Bump the changelog.
method !bump-changelog (
	Config:D $config,
	Str:D $version,
) {
	return if $config<runtime><no-bump-changelog>;

	my IO::Path $changelog = $config<cwd>.add("CHANGELOG.md");

	return unless $changelog.e && $changelog.f;

	my Str $updated-file = "";
	my Str $datestamp = Date.new(now).yyyy-mm-dd;

	for $changelog.lines -> $line {
		given $line {
			when / ^ ( "#"+ \h+ ) "[UNRELEASED]" / {
				$updated-file ~= "{$0}[$version] - $datestamp\n";
			}
			default {
				$updated-file ~= "$line\n";
			}
		}
	}

	$changelog.spurt($updated-file);
}

#| Bump the =VERSION blocks in pod sections found in files declared in
#| META6.json's "provides" key.
method !bump-provides (
	Config:D $config,
	Str:D $version,
	*@files,
) {
	return if $config<runtime><no-bump-provides>;

	for @files -> $relative-file {
		my IO::Path $file = $config<cwd>.add($relative-file);
		my Str $updated-file = "";

		for $file.lines -> $line {
			given $line {
				when / ^ ( \h* "=VERSION" \s+ ) \S+ (.*)/ {
					$updated-file ~= "{$0}{$version}{$1}\n";
				}
				default {
					$updated-file ~= "$line\n";
				}
			}
		}

		spurt($file, $updated-file);
	}
}

=begin pod

=NAME    App::Assixt::Commands::Bump
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt bump <level>

=head2 Levels

=defn major
The major level is the first part of the version string. This should be bumped
in case a change is introduced which is not backwards compatible.

=defn minor
The minor level is the second part of the version string. This should be bumped
in case a change is introduced which is backwards compatible. This is almost
always the case when you introduce a new feature into your module.

=defn patch
The patch level is the third part of the version string. This should be bumped
in case a change is introduced which fixes a bug, or otherwise improves the
module without altering the functionality it exposes. If the user gains no new
features, and does not have to alter their code for a change in your module,
you most likely want to bump this part.

=head1 Description

Bump the version number of the module. This will update the C<version> key in
the C<META6.json>, as well as the C<=VERSION> meta blocks in the Perl 6 Pod
sections of the module files.

C<App::Assixt> uses the L<Semantic Versioning|https://semver.org> specification
to handle version numbers in B<all> circumstances.

=head1 Examples

    assixt bump major
    assixt bump minor
    assixt bump patch

=head1 See also

=item1 C<App::Assixt>
=item1 L<Semantic Versioning|https://semver.org>

=end pod

# vim: ft=perl6 noet
