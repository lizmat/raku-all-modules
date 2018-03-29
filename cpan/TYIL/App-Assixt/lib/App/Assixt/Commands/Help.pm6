#! /usr/bin/env false

use v6.c;

use App::Assixt::Usage;
use Config;

class App::Assixt::Commands::Help
{
	method run(Config:D :$config)
	{
		USAGE
	}
}
