#! /usr/bin/env false

use v6.c;

use Config;

class App::Assixt::Commands::Bootstrap
{
	method run(*@args, Config:D :$config)
	{
		my $type = @args.head.tclc;
		my $lib = "App::Assixt::Commands::Bootstrap::$type";

		try require ::($lib);

		if (::($lib) ~~ Failure) {
			note "No idea what to do with a $type";

			if ($config<verbose>) {
				note ::($lib).Str;
			}

			exit 2;
		}

		::($lib).run(|@args, :$config);
	}
}

# vim: ft=perl6 noet
