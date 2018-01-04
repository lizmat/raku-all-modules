#! /usr/bin/env false

use v6.c;

use App::Assixt::Input;
use Dist::Helper::Clean;
use Dist::Helper::Meta;

unit module App::Assixt::Commands::Clean;

multi sub MAIN(
	"clean",
	Str:D $path = ".",
	Bool:D :$no-meta = False,
	Bool:D :$no-files = False,
	Bool:D :$force = False,
	Bool:D :$verbose = False,
) is export {
	# Clean up the META6.json
	unless ($no-meta) {
		my %meta = clean-meta(:$path, :$force, :$verbose);

		put-meta(:%meta, :$path) if $force || confirm("Save cleaned META6.json?");
	}

	# Clean up unreferenced files
	unless ($no-files) {
		my @orphans = clean-files(:$path, :$force, :$verbose);

		for @orphans -> $orphan {
			unlink($orphan) if $force || confirm("Really delete $orphan?");
		}
	}

	True;
}

# vim: ft=perl6 noet
