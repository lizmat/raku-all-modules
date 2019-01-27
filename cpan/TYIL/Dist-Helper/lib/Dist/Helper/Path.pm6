#! /usr/bin/env false

use v6.c;

use Dist::Helper;

unit module Dist::Helper::Path;

multi sub get-dist-path(
	Str:D $name,
	Str:D $version,
	Str:D $prefix = ".",
	--> Str
) is export {
	$prefix.IO.add(make-dist-fqdn($name, $version) ~ ".tar.gz").absolute;
}

sub make-path-absolute(
	Str:D $path
	--> Str
) is export {
	$path.IO.absolute;
}

sub make-paths-absolute(
	@paths --> Array[Str]
) is export {
	my Str @absolute-paths;

	for @paths -> $path {
		@absolute-paths.push: make-path-absolute($path);
	}

	@absolute-paths;
}
