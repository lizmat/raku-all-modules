#! /usr/bin/env false

use v6.c;

use Config;

class App::Assixt::Commands::Test
{
	method run(
		Config:D :$config,
	) {
		run(« prove -e "perl6 -Ilib" »).so
	}
}
