#! /usr/bin/env false

use v6.c;

unit module App::Cpan6::Commands::Help;

sub USAGE is export
{
	for %?RESOURCES<helpfile>.lines { .say }
}

multi sub MAIN("help") is export
{
	USAGE
}
