#! /usr/bin/env false

use v6.c;

use Dist::Helper::Meta;

unit module Dist::Helper::Clean;

sub clean-files (
	Str:D :$path,
	Bool:D :$force = False,
	Bool:D :$verbose = False,
	--> Array
) is export {
	my %meta = get-meta;
	my @orphans = ();

	# Clean up bin and lib directories
	for < bin lib > -> $directory {
		for find-files($directory) -> $file {
			next if ~$file ~~ /\.precomp/;
			next if %meta<provides>.values ∋ ~$file;

			@orphans.push: $file;
		}
	}

	# Clean up resources
	for find-files("resources") -> $file {
		next if %meta<resources> ∋ $file.subst("resources/", "");

		@orphans.push: $file;
	}

	@orphans;
}

sub clean-meta (
	Str:D :$path = ".",
	Bool:D :$force = False,
	Bool:D :$verbose = False,
	--> Hash
) is export {
	my %meta = get-meta($path);
	my %provides;
	my @resources;

	# Clean up provides
	for %meta<provides>.kv -> $key, $value {
		if ($value.IO.e) {
			%provides{$key} = $value;

			next;
		}

		say "Removing provides.$key ($value)" if $verbose;
	}

	# Clean up resources
	for %meta<resources>.values -> $value {
		if ("resources/$value".IO.e) {
			@resources.push: $value;

			next
		}

		say "Removing resources.$value" if $verbose;
	}

	%meta<provides> = %provides;
	%meta<resources> = @resources;

	%meta;
}

multi sub find-files (
	Str:D $path
	--> List
) is export {
	find-files($path.IO)
}

multi sub find-files (
	IO::Path:D $path
	--> List
) is export {
	my @files;

	for $path.dir -> $object {
		if ($object.IO.d) {
			@files.append: find-files($object);

			next;
		}

		@files.append: $object;
	}

	@files;
}

# vim: ft=perl6 noet
