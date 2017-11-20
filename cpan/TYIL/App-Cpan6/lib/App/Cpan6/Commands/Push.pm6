#! /usr/bin/env false

use v6;

use App::Cpan6;
use App::Cpan6::Commands::Dist;
use App::Cpan6::Commands::Bump;
use App::Cpan6::Commands::Upload;
use App::Cpan6::Meta;
use App::Cpan6::Path;

unit module App::Cpan6::Commands::Push;

multi sub MAIN("push", $path, :$no-bump = False) is export
{
	# Change to the given directory
	chdir $path;

	# Call all required actions in order
	MAIN("bump", $path, :!ask) unless $no-bump;

	my %meta = get-meta;

	MAIN("upload", get-dist-path(%meta<name>, %meta<version>));
}

multi sub MAIN("push", :$no-bump = False) is export
{
	MAIN("push", ".", :$no-bump);
}

multi sub MAIN("push", @paths, :$no-bump = False) is export
{
	for make-paths-absolute(@paths) -> $path {
		MAIN("push", $path, :$no-bump);
	}
}
