#! /usr/bin/env false

use v6.c;

use Config;

class App::Assixt::Commands::Touch
{
	method run(*@args, Config:D :$config)
	{
		my $type = @args.head.tclc;
		my $lib = "App::Assixt::Commands::Touch::$type";

		try require ::($lib);

		if (::($lib) ~~ Failure) {
			note "No idea how to touch a $type";

			if ($config<verbose>) {
				note ::($lib).Str;
			}

			exit 2;
		}

		::($lib).run(|@args, :$config);
	}
}

# vim: noet ts=4 sw=4
