#! /usr/bin/env false

use v6.c;

use Template::Mustache;

unit module App::Cpan6::Package::Ebuild;

sub atom-name(Str $name, Any $version) returns Str is export
{
	"{ebuild-name($name)}-{$version.Str}"
}

sub ebuild-name(Str $name) returns Str is export
{
	"p6-" ~ $name.lc.subst('::', '-', :g)
}

sub make-ebuild(%meta) returns Str is export
{
	# Check for required elements
	my Str @required-fields = (
		"description",
		"license",
		"name",
		"source-url",
		"version",
	);

	for @required-fields -> $field {
		if (%meta{$field}:!exists) {
			die "Missing required field from META6.json: $field";
		}
	}

	# List all dependencies
	my Str @dependencies;

	for %meta<depends>.list -> $dependency {
		@dependencies.push(atom-name(%meta<name>, 9999));
	}

	# Generate ebuild
	my Str %context =
		dependencies => @dependencies.join(" "),
		description => %meta<description>,
		license => %meta<license>,
		name => ebuild-name(%meta<name>),
		src_uri => %meta<source-url>,
	;

	Template::Mustache.render(%?RESOURCES<templates/ebuild>.slurp, %context);
}
