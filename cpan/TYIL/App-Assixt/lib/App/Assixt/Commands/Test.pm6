#! /usr/bin/env false

use v6.c;

use Config;

unit module App::Assixt::Commands::Test;

multi sub assixt(
	"test",
	Config:D :$config,
) is export {
	run « prove -e "perl6 -Ilib" »
}
