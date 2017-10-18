#! /usr/bin/env false

use v6;

use App::Cpan6;
use App::Cpan6::Commands::Dist;
use App::Cpan6::Commands::Release;
use App::Cpan6::Commands::Upload;
use App::Cpan6::Meta;
use App::Cpan6::Path;

unit module App::Cpan6::Commands::Push;

multi sub MAIN("push", $path, :$no-release = False) is export
{
	# Change to the given directory
	chdir $path;

	# Call all required actions in order
	MAIN("release", $path, :!ask) unless $no-release;

	my %meta = get-meta;

	MAIN("upload", get-dist-path(%meta<name>, %meta<version>));

	# Friendly output
	say "Released and uploaded {%meta<name>} v{%meta<version>}";
}

multi sub MAIN("push", :$no-release = False) is export
{
	MAIN("push", ".", :$no-release);
}

multi sub MAIN("push", @paths, :$no-release = False) is export
{
	for make-paths-absolute(@paths) -> $path {
		MAIN("push", $path, :$no-release);
	}
}
