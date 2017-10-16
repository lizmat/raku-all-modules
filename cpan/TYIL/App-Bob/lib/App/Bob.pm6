#! /usr/bin/env false

use v6.c;

use JSON::Fast;

unit module App::Bob;

sub get-meta($path = ".") is export
{
	my $meta6 = $path.IO.add("META6.json");

	if (! $meta6.e) {
		die "No META6.json in {$path.IO.absolute}";
	}

	from-json(slurp($meta6.path));
}

sub get-dist-fqdn(%meta --> Str) is export
{
	return "{get-dist-name(%meta)}-{get-dist-version(%meta)}";
}

sub get-dist-name(%meta --> Str) is export
{
	if (%meta<name>:!exists) {
		die "No name attribute in meta";
	}

	return %meta<name>.subst("::", "-", :g).trim;
}

sub get-dist-version(%meta --> Str) is export
{
	if (%meta<version>:!exists) {
		die "No version attribute in meta";
	}

	return %meta<version>.trim;
}

sub put-meta(:%meta, :$path = ".", :$clobber = True) is export
{
	my $meta6 = $path.IO.add("META6.json").absolute;

	if ($meta6.IO.e && !$clobber) {
		die "Not clobbering {$meta6}";
	}

	spurt($meta6, to-json(%meta))
}

sub confirm(Str $prompt = "Continue?", Bool $default = True --> Bool) is export
{
	my Str $options;

	if ($default) {
		$options = "Y/n";
	} else {
		$options = "y/N";
	}

	loop {
		my $input = prompt "$prompt [$options] ";

		if ($input eq "") {
			return $default;
		}

		if ($input ~~ m:i/y[es]?/) {
			return True;
		}

		if ($input ~~ m:i/no?/) {
			return False;
		}
	}
}

sub ask(Str $message, Str :$default = "" --> Str) is export
{
	my Str $prompt = $message;

	if ($default ne "") {
		$prompt ~= " [$default]";
	}

	$prompt ~= ": ";

	loop {
		my $input = prompt $prompt;

		return $input if $input ne "";
		return $default if $default ne "";
	}
}
