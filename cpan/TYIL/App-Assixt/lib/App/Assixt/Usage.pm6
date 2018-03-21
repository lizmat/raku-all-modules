#! /usr/bin/env false

use v6.c;

unit module App::Assixt::Usage;

sub USAGE is export
{
	%?RESOURCES<docopt.txt>.slurp.say;
}

# vim: ft=perl6 noet
