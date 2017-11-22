#! /usr/bin/env false

use v6.c;

use File::Which;

unit module App::Cpan6::Commands::Bootstrap::Man;

multi sub MAIN(
	"bootstrap",
	"man",
	Str:D :$dir= "/usr/share/man",
	Bool:D :$verbose = False,
) is export {
	my @pages = (
		"cpan6.1",
	);

	for @pages -> $page {
		MAIN("bootstrap", "man", $page, dir => $dir.IO.absolute, :$verbose);
	}
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
	die "a2x is not installed" unless which("a2x");

	chdir $source.IO.parent.path;

	run « a2x -f manpage {$verbose ?? "-v" !! ""} {$source.IO.path} »;
	run « gzip "$page" »;
	mkdir $destination.IO.parent.path;

	if (!move "$page.gz", $destination) {
		note "Moving $page.gz to $destination failed";
	}
}

# vim: ft=perl6 noet
