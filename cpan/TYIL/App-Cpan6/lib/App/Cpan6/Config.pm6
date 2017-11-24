#! /usr/bin/env false

use v6;

use Config;

unit module App::Cpan6::Config;

sub get-config(Bool:D :$no-user-config = False --> Config) is export
{
	my Config $config .= new;

	# Set default config
	$config.read: %(
		cpan6 => %(
			distdir => "{$*HOME}/.local/var/cpan6/dists",
		),
		new-module => %(
			author => "",
			email => "",
			perl => "c",
			license => "GPL-3.0",
			dir-prefix => "perl6-",
		),
		external => %(
			git => True,
			travis => True,
		),
		style => %(
			indent => "tab",
			spaces => 4,
		),
		pause => %(
			id => ""
		),
	);

	# Add user config
	unless ($no-user-config) {
		my Str @paths =
			"{$*HOME}/.config/cpan6.toml"
		;

		for @paths -> $path {
			if (!$path.IO.e) {
				next;
			}

			$config.read: $path;
		}
	}

	# Add environment config
	for $config.keys -> $key {
		my $env = "CPAN6_" ~ $key.subst(/\-|\./, "_", :g).uc;

		next unless %*ENV{$env}:exists;

		$config.set($key, %*ENV{$env});
	}

	$config;
}

multi sub put-config(Config:D :$config, Str:D :$path) is export
{
	$config.write($path);
}

multi sub put-config(Config:D :$config) is export
{
	put-config(:$config, :path("$*HOME/.config/cpan6.toml"))
}
