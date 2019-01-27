#! /usr/bin/env false

use v6.c;

use App::Assixt::Commands::New;
use App::Assixt::Config;
use Config;

unit module App::Assixt::Test;

sub run-bin(
	IO::Path:D $assixt-dir,
	*@args,
) is export {
	my @runnable = «
		"$*EXECUTABLE"
		-I "$assixt-dir/lib"
		"$assixt-dir/bin/assixt"
		--/user-config
	»;

	@runnable.push: |@args;

	run @runnable;
}

multi sub create-test-module(
	Str:D $name = "Local::Test::Assixt",
	IO::Path:D $directory = $*CWD,
	%config-overrides = %(),
) is export {
	my Config $config = get-config(:!user-config);

	$config.read: %(
		runtime => %(
			name => $name,
			author => "Patrick Spek",
			email => "p.spek@tyil.work",
			perl => "c",
			description => "Nondescript",
			license => "AGPL-3.0",
			source-url => "Localhost",
			auth => "gitlab:tyil",
			cwd => $directory,
		),
	);

	$config.read: %config-overrides;

	App::Assixt::Commands::New.run(:$config);
}
