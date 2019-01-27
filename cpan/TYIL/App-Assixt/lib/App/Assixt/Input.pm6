#! /usr/bin/env false

use v6.c;

use Terminal::Getpass;

unit module App::Assixt::Input;

multi sub ask (
	Str:D $message,
	Any:D :$default = "",
	Bool:D :$empty = False,
	--> Str
) is export {
	my Str $prompt = $message;

	if (~$default ne "") {
		$prompt ~= " [{~$default}]";
	}

	$prompt ~= ": ";

	loop {
		my $input = prompt $prompt;

		return $input if $input ne "";
		return ~$default if ~$default ne "";
		return "" if $empty;
	}
}

multi sub ask (
	Str:D $message,
	Any:D $default = "",
	Bool:D :$empty = False,
	--> Str
) is export {
	samewith($message, :$default, :$empty);
}

multi sub ask (
	Str:D $message,
	Bool:D $empty = False,
	--> Str
) is export {
	samewith($message, "", :$empty);
}

multi sub confirm (
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

multi sub confirm (
	Str:D $prompt = "Continue?",
	Bool:D $default = True
	--> Bool
) is export {
	confirm($prompt, :$default);
}

sub password (
	Str:D $prompt = "Password",
	--> Str
) is export {
	getpass("$prompt: ");
}
