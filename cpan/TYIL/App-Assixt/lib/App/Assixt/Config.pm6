#! /usr/bin/env false

use v6.c;

use Config;

unit module App::Assixt::Config;

sub get-config(
	:$config-file,
	Bool:D :$no-user-config = False,
	--> Config
) is export {
	my Config $config .= new;

	# Set default config
	$config.read: %(
		assixt => %(
			distdir => "{$*HOME}/.local/var/assixt/dists",
		),
		external => %(
			git => True,
			travis => True,
		),
		new-module => %(
			author => "",
			email => "",
			perl => "c",
			license => "GPL-3.0",
			dir-prefix => "perl6-",
		),
		style => %(
			indent => "tab",
			spaces => 4,
		),
		pause => %(
			id => ""
		),
	);

	my Str @paths;

	unless ($no-user-config) {
		@paths =
			"{$*HOME}/.config/assixt.toml",
		;
	}

	@paths.append: $config-file if $config-file;

	# Add config from files
	for @paths -> $path {
		next if !$path.IO.e;

		$config.read: $path;
	}

	# Add config from environment
	for $config.keys -> $key {
		my $env = "ASSIXT_" ~ $key.subst(/\-|\./, "_", :g).uc;

		next unless %*ENV{$env}:exists;

		$config.set($key, %*ENV{$env});
	}

	$config;
}

multi sub put-config(Config:D :$config, Str:D :$path) is export
{
	return put-config(:$config) if $path eq "";

	$config.write($path);
}

multi sub put-config(Config:D :$config) is export
{
	put-config(:$config, :path("$*HOME/.config/assixt.toml"))
}
