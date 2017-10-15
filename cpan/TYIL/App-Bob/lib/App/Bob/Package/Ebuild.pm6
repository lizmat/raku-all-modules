#! /usr/bin/env false

use v6.c;

use Template::Mustache;

unit module App::Bob::Package::Ebuild;

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

	Template::Mustache.render(template, %context).trim;
}

sub template() returns Str is export
{
	q:to/EOF/
# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="{{ description }}"
HOMEPAGE="{{ src_uri }}"

EGIT_REPO_URI="{{ src_uri }}"
EGIT_COMMIT="v${PV}"
EGIT_CHECKOUT_DIR=${S}/

LICENSE="{{ license }}"
SLOT="0"
KEYWORDS="~*"
IUSE=""

DEPEND="dev-perl/p6-zef"
RDEPEND="{{ dependencies }}"

pkg_install() {
	zef --install-to=/usr/share/perl6/site install .
}
EOF
}

