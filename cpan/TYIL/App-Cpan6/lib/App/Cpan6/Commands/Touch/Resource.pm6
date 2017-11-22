#! /usr/bin/env false

use v6.c;

use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Touch::Resource;

multi sub MAIN("touch", "resource", Str:D $resource) is export
{
	my %meta = get-meta;

	mkdir "resources" unless "resources".IO.d;
	chdir "resources";

	my $path = ".".IO.add($resource);

	# Check for duplicate entry
	if (%meta<resources> ∋ $path.relative) {
		note "A $resource already exists in {%meta<name>}";
		return;
	}

	# Create the resource
	my $parent = $path.parent.absolute;

	mkdir $parent unless $parent.IO.d;
	spurt($path, "") unless $path.IO.e;

	# Add the resource to the META6.json
	%meta<resources>.push: $path.relative;
	put-meta(:%meta, path => "..");

	# User-friendly output
	say "Added resource $resource to {%meta<name>}";
}
