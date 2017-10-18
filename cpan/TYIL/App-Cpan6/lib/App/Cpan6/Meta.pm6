#! /usr/bin/env false

use v6;

use JSON::Fast;

unit module App::Cpan6::Meta;

sub get-meta($path = ".") is export
{
	my $meta6 = $path.IO.add("META6.json");

	if (! $meta6.e) {
		die "No META6.json in {$path.IO.absolute}";
	}

	from-json(slurp($meta6.path));
}

sub put-meta(:%meta, :$path = ".", :$clobber = True) is export
{
	my $meta6 = $path.IO.add("META6.json").absolute;

	if ($meta6.IO.e && !$clobber) {
		die "Not clobbering {$meta6}";
	}

	spurt($meta6, to-json(%meta))
}
