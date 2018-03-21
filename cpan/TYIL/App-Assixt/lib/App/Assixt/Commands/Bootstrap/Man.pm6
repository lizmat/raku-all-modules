#! /usr/bin/env false

use v6.c;

use Config;
use File::Which;

unit module App::Assixt::Commands::Bootstrap::Man;

multi sub assixt(
	"bootstrap",
	"man",
	Str:D $page,
	Config:D :$config,
) is export {
	$config<runtime><dir> //= "/usr/share/man";

	my $source = %?RESOURCES{"man/$page.adoc"};
	my $destination = "$config<runtime><dir>/man" ~ $page.split(".")[*-1] ~ "/$page.gz";

	die "Invalid source $page" unless $source;
	die "'a2x' is not available on this system" unless which("a2x");
	die "'gzip' is not available on this system" unless which("gzip");

	chdir $source.IO.parent.path;

	run « a2x -f manpage {$config<verbose> ?? "-v" !! ""} "{$source.IO.path}" »;
	say $source.IO.path;
	say $page;
	run « gzip "$page" »;
	mkdir $destination.IO.parent.path;

	if (!move "$page.gz", $destination) {
		note "Moving $page.gz to $destination failed";
	}

	True;
}

multi sub assixt(
	"bootstrap",
	"man",
	Config:D :$config,
) is export {
	$config<runtime><dir> //= "/usr/share/man";

	my @pages = (
		"assixt.1",
	);

	for @pages -> $page {
		assixt(
			"bootstrap",
			"man",
			$page,
			:$config
		);
	}

	True;
}

# vim: ft=perl6 noet
