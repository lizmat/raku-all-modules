#! /usr/bin/env false

use v6.c;

unit module App::Assixt::Test;

sub run-bin(
	IO::Path:D $assixt-dir,
	*@args,
) is export {
	my @runnable = «
		"$*EXECUTABLE"
		-I "$assixt-dir/lib"
		"$assixt-dir/bin/assixt"
		--no-user-config
	»;

	@runnable.push: |@args;

	run @runnable;
}

sub create-test-module(
	IO::Path:D $assixt-dir,
	Str:D $name = "Local::Test::Assixt",
) is export {
	run-bin($assixt-dir, «
		new
		"--name=\"$name\""
		'--author="Patrick Spek"'
		--email=p.spek@tyil.work
		--perl=c
		--description=Nondescript
		--license=GPL-3.0
	»);
}
