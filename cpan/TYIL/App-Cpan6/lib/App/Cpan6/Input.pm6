#! /usr/bin/env false

use v6;

use Terminal::Readsecret;

unit module App::Cpan6::Input;

sub ask(Str $message, Str :$default = "" --> Str) is export
{
	my Str $prompt = $message;

	if ($default ne "") {
		$prompt ~= " [$default]";
	}

	$prompt ~= ": ";

	loop {
		my $input = prompt $prompt;

		return $input if $input ne "";
		return $default if $default ne "";
	}
}

sub confirm(Str $prompt = "Continue?", Bool $default = True --> Bool) is export
{
	my Str $options;

	if ($default) {
		$options = "Y/n";
	} else {
		$options = "y/N";
	}

	loop {
		my $input = prompt "$prompt [$options] ";

		if ($input eq "") {
			return $default;
		}

		if ($input ~~ m:i/y[es]?/) {
			return True;
		}

		if ($input ~~ m:i/no?/) {
			return False;
		}
	}
}

sub password(Str $prompt = "Password" --> Str) is export
{
	getsecret("$prompt: ");
}
