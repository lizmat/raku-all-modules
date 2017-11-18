#! /usr/bin/env false

use v6.c;

unit module App::Cpan6::Commands::Test;

multi sub MAIN("test") is export
{
	run « prove -e "perl6 -Ilib" »
}
