#! /usr/bin/env false

use v6.c;

use Config;
use File::Which;

class App::Assixt::Commands::Bootstrap::Man
{
	multi method run(
		"man",
		Str:D $page,
		Config:D :$config,
	) {
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

	multi method run(
		"man",
		Config:D :$config,
	) {
		$config<runtime><dir> //= "/usr/share/man";

		my @pages = (
			"assixt.1",
		);

		for @pages -> $page {
			self.run(
				"man",
				$page,
				:$config
			);
		}
	}
}

# vim: ft=perl6 noet
