#! /usr/bin/env false

use v6.c;

unit module App::Assixt::Commands::Test;

multi sub MAIN("test") is export
{
	run « prove -e "perl6 -Ilib" »
}
