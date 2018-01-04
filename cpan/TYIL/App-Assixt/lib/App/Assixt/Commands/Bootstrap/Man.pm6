#! /usr/bin/env false

use v6.c;

use File::Which;

unit module App::Assixt::Commands::Bootstrap::Man;

multi sub MAIN(
	"bootstrap",
	"man",
	Str:D :$dir= "/usr/share/man",
	Bool:D :$verbose = False,
) is export {
	my @pages = (
		"assixt.1",
	);

	for @pages -> $page {
		MAIN("bootstrap", "man", $page, dir => $dir.IO.absolute, :$verbose);
	}

	True;
}

multi sub MAIN(
	"bootstrap",
	"man",
	Str:D $page,
	Str:D :$dir= "/usr/share/man",
	Bool :$verbose = False,
) is export {
	my $source = %?RESOURCES{"man/$page.adoc"};
	my $destination = "$dir/man" ~ $page.split(".")[*-1] ~ "/$page.gz";

	die "Invalid source $page" unless $source;
	die "'a2x' is not available on this system" unless which("a2x");
	die "'gzip' is not available on this system" unless which("gzip");

	chdir $source.IO.parent.path;

	run « a2x -f manpage {$verbose ?? "-v" !! ""} {$source.IO.path} »;
	say $source.IO.path;
	say $page;
	run « gzip $page »;
	mkdir $destination.IO.parent.path;

	if (!move "$page.gz", $destination) {
		note "Moving $page.gz to $destination failed";
	}

	True;
}

# vim: ft=perl6 noet
