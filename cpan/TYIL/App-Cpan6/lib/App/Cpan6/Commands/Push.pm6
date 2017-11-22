#! /usr/bin/env false

use v6;

use App::Cpan6;
use App::Cpan6::Commands::Dist;
use App::Cpan6::Commands::Bump;
use App::Cpan6::Commands::Upload;
use App::Cpan6::Meta;
use App::Cpan6::Path;

unit module App::Cpan6::Commands::Push;

multi sub MAIN(
	"push",
	Str:D $path,
	Bool :$force = False,
	Bool :$no-bump = False,
) is export {
	# Change to the given directory
	chdir $path;

	# Call all required actions in order
	MAIN("bump") unless $no-bump;
	MAIN("dist", :$force);

	my %meta = get-meta;

	MAIN("upload", get-dist-path(%meta<name>, %meta<version>));
}

multi sub MAIN(
	"push",
	Bool :$force = False,
	Bool :$no-bump = False,
) is export {
	MAIN("push", ".", :$force, :$no-bump);
}

multi sub MAIN(
	"push",
	@paths,
	Bool :$force = False,
	Bool :$no-bump = False,
) is export {
	for make-paths-absolute(@paths) -> $path {
		MAIN("push", $path, :$force, :$no-bump);
	}
}
