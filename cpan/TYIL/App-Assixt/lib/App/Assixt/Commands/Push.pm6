#! /usr/bin/env false

use v6.c;

use App::Assixt::Commands::Bump;
use App::Assixt::Commands::Dist;
use App::Assixt::Commands::Upload;
use App::Assixt::Config;
use Dist::Helper::Meta;
use Dist::Helper::Path;
use Dist::Helper;

unit module App::Assixt::Commands::Push;

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

	MAIN(
		"upload",
		get-dist-path(
			%meta<name>,
			%meta<version>,
			get-config()<assixt><distdir>
		),
	);
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
