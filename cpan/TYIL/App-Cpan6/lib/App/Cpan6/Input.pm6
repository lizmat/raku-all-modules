#! /usr/bin/env false

use v6;

use Terminal::Readsecret;

unit module App::Cpan6::Input;

multi sub ask(Str $message, Any :$default = "" --> Str) is export
{
	my Str $prompt = $message;

	if (~$default ne "") {
		$prompt ~= " [{~$default}]";
	}

	$prompt ~= ": ";

	loop {
		my $input = prompt $prompt;

		return $input if $input ne "";
		return ~$default if ~$default ne "";
	}
}

multi sub ask(Str:D $message, Any:D $default = "" --> Str) is export
{
	ask($message, :$default);
}

multi sub confirm(
	Str $prompt = "Continue?",
	Bool :$default = True
	--> Bool
) is export {
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

multi sub confirm(
	Str:D $prompt = "Continue?",
	Bool:D $default = True
	--> Bool
) is export {
	confirm($prompt, :$default);
}

sub password(Str $prompt = "Password" --> Str) is export
{
	getsecret("$prompt: ");
}
