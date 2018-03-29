#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Usage;
use Config;

unit module App::Assixt::Main;

sub MAIN(
	Str $command = "help",
	*@args,
	Str :$config-file,
	Bool :$force = False,
	Bool :$no-user-config = False,
	Bool :$verbose = False,
) is export {
	my Config $config = get-config(:$config-file, :$no-user-config);

	$config<runtime> = %();
	$config<force> = $force;
	$config<verbose> = $verbose;

	@args = parse-args(@args, :$config);

	my $lib = "App::Assixt::Commands::$command.tclc()";

	try require ::($lib);

	if (::($lib) ~~ Failure) {
		note "Command $command wasn't recognized. Try -h for usage help.";

		if ($config<verbose>) {
			note ::($lib).Str;
		}

		exit 2;
	}

	::($lib).run(|@args, :$config);

	True;
}

sub parse-args(
	@args,
	Config :$config,
) {
	my @leftovers = ();

	for @args -> $arg {
		if (!$arg.starts-with("--")) {
			@leftovers.push: $arg;

			next;
		}

		my $key = $arg.substr(2);
		my $value = True;

		if ($key.contains("=")) {
			($key, $value) = $key.split("=", 2);

			if ($value.starts-with('"'|"'") && $value.ends-with('"'|"'")) {
				$value .= substr(1, *-1);
			}
		}

		$config<runtime>{$key} = $value;
	}

	return @leftovers;
}

# vim: ft=perl6 noet
