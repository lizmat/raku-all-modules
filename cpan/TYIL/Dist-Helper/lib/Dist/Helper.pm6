#! /usr/bin/env false

use v6.c;

use JSON::Fast;

unit module Dist::Helper;

sub get-dist-fqdn(%meta --> Str) is export
{
	return "{get-dist-name(%meta)}-{get-dist-version(%meta)}";
}

sub get-dist-name(%meta --> Str) is export
{
	if (%meta<name>:!exists) {
		die "No name attribute in meta";
	}

	return make-dist-name(%meta<name>);
}

sub get-dist-version(%meta --> Str) is export
{
	if (%meta<version>:!exists) {
		die "No version attribute in meta";
	}

	return %meta<version>.trim;
}

sub make-dist-name(Str $name --> Str) is export
{
	$name.subst("::", "-", :g).trim;
}

sub make-dist-fqdn(Str $name, Str $version --> Str) is export
{
	"{make-dist-name($name)}-$version";
}
