#! /usr/bin/env false

use v6.c;

use Dist::Helper;
use Config;

unit module Dist::Helper::Path;

multi sub get-dist-path(Str $name, Str $version, Config:D :$config --> Str) is export
{
	$config.get("cpan6.distdir").IO.add(make-dist-fqdn($name, $version) ~ ".tar.gz").absolute;
}

sub make-path-absolute($path --> Str) is export
{
	$path.IO.absolute;
}

sub make-paths-absolute(@paths --> Array[Str]) is export
{
	my Str @absolute-paths;

	for @paths -> $path {
		@absolute-paths.push: make-path-absolute($path);
	}

	@absolute-paths;
}
