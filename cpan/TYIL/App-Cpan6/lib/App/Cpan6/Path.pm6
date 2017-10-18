#! /usr/bin/env false

use v6;

use App::Cpan6;
use App::Cpan6::Config;
use Config;

unit module App::Cpan6::Path;

multi sub get-dist-path(Str $name, Str $version, Config:D :$config --> Str) is export
{
	$config.get("cpan6.distdir").IO.add(make-dist-fqdn($name, $version) ~ ".tar.gz").absolute;
}

multi sub get-dist-path(Str $name, Str $version --> Str) is export
{
	get-dist-path($name, $version, config => get-config);
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
