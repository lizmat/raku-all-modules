#! /usr/bin/env false

use v6;

use App::Cpan6;
use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Dist;

multi sub MAIN("dist", *@paths, Bool :$force = False) is export
{
	my Str @absolute-paths;

	# Default to the current directory
	if (@paths.elems < 1) {
		@paths.push: ".";
	}

	for @paths -> $path {
		@absolute-paths.push: $path.IO.absolute;
	}

	for @absolute-paths -> $path {
		chdir $path;

		if (!"./META6.json".IO.e) {
			note "No META6.json in {$path}";
			next;
		}

		my %meta = get-meta;

		my Str $fqdn = get-dist-fqdn(%meta);
		my Str $basename = $*CWD.IO.basename;
		my Str $transform = "s/^\./{$fqdn}/";
		my Str $output = "{$*HOME}/.local/var/cpan6/dists/{$fqdn}.tar.gz";

		# Ensure output directory exists
		mkdir $output.IO.parent;

		if ($output.IO.e && !$force) {
			note "Archive already exists: {$output}";
			next;
		}

		my $proc = run «
			tar czf {$output}
			--transform {$transform}
			--exclude-vcs
			--exclude-vcs-ignores
			--exclude=.[^/]*
			.
		», :err;

		say "Created {$output}";
	}
}
