#! /usr/bin/env false

use v6.c;

use Config;
use App::Assixt::Commands::Touch::Lib;

class App::Assixt::Commands::Touch::Class
{
	method run(*@args, :$config)
	{
		App::Assixt::Commands::Touch::Lib.run(|@args, :$config);
	}
}

# vim: ft=perl6 noet
