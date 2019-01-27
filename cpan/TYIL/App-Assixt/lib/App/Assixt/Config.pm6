#! /usr/bin/env false

use v6.c;

use Config;

unit module App::Assixt::Config;

sub get-config (
	:$config-file,
	Bool:D :$user-config = True,
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
			gitlab-ci => True,
		),
		new-module => %(
			author => "",
			email => "",
			auth => "",
			perl => "c",
			license => "AGPL-3.0",
			dir-prefix => "perl6-",
		),
		style => %(
			indent => "tab",
			spaces => 4,
		),
		pause => %(
			id => "",
			tries => 3,
		),
	);

	my Str @paths;

	if ($user-config) {
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

	# Add special values
	$config<cwd> = $*CWD;
	$config<force> = False;
	$config<verbose> = False;
	$config<config-file> = $config-file if $config-file;

	# Add config from environment
	for $config.keys -> $key {
		my $env = "ASSIXT_" ~ $key.subst(/\-|\./, "_", :g).uc;

		next unless %*ENV{$env}:exists;

		$config.set($key, %*ENV{$env});
	}

	$config;
}

multi sub put-config (
	Config:D :$config,
	Str:D :$path,
) is export {
	return put-config(:$config) if $path eq "";

	my Config $clean-config = $config.clone;

	config-ignored().map({ $clean-config{$_}:delete if $clean-config{$_}:exists });

	$clean-config.write($path);

	$config;
}

multi sub put-config (
	Config:D :$config;
) is export {
	samewith(:$config, :path("$*HOME/.config/assixt.toml"))
}

sub config-ignored (
	--> Positional
) is export {
	<
		config-file
		cwd
		force
		runtime
		verbose
	>
}

=begin pod

=head1 Description

This document lists the configuration options available to C<assixt>, with
descriptions of their uses and default values. If you want to walk through all
the configuration options interactively, read
C<App::Assixt::Commands::Bootstrap::Config>.

=head1 Configuration options

=head2 assixt

The C<assixt> configuration set deals with configuration options that fit in no
specific category.

=head3 distdir

=item1 Key: C<assixt.distdir>
=item1 Type: C<Str>
=item1 Default: C<{$*HOME}/.local/var/assixt/dists>

The C<assixt.distdir> configuration key sets the location for newly created
module distribution tarballs, created with
L<C<dist>|App::Assixt::Commands::Dist>.

=head2 external

The C<external> configuration set deals with settings that inform C<assixt> on
how to deal with external programs. If these are set to C<False>, C<assixt>
will do no effort to play nice with them.

Generally, if support is enabled, L<C<new>|App::Assixt::Commands::New> will add
in additional configuration files to the repository to make use of these
external tools.

=head3 git

=item1 Key: C<external.git>
=item1 Type: C<Bool>
=item1 Default: C<True>

=head3 travis

=item1 Key: C<external.travis>
=item1 Type: C<Bool>
=item1 Default: C<True>

=head3 gitlab-ci

=item1 Key: C<external.gitlab-ci>
=item1 Type: C<Bool>
=item1 Default: C<True>

=head2 new-module

The C<new-module> configuration set deals with options that are used when
creating a new module. These are mostly default values to be inserted when
modules are being made using L<C<new>|App::Assixt::Commands::New>.
item1 Default: C<True>

=head3 author

=item1 Key: C<new-module.author>
=item1 Type: C<Str>
=item1 Default: C<"">

When using C<new>, only one module author can be specified. However, you can
later use L<C<meta add-author>|App::Assixt::Commands::Meta::AddAuthor> to add
in more authors.

=head3 email

=item1 Key: C<new-module.email>
=item1 Type: C<Str>
=item1 Default: C<"">

This is the email address attached to the module's author name.

=head3 perl

=item1 Key: C<new-module.perl>
=item1 Type: C<Str>
=item1 Default: C<"c">

=head3 license

=item1 Key: C<new-module.license>
=item1 Type: C<Str>
=item1 Default: C<"AGPL-3.0">

=head3 dir-prefix

=item1 Key: C<new-module.dir-prefix>
=item1 Type: C<Str>
=item1 Default: C<"perl6-">

This is the prefix used for new module directories. If you don't want any
prefix, set this to an empty Str.

=head2 style

The C<style> configuration set deals with options regarding to coding style.
New modules are initialized with a C<.editorconfig> file, and the options given
here are used to generate the correct values in that file. Additionally, new
files created with L<C<touch>|App::Assixt::Commands::Touch> will receive a vim
modeline at the end.

=head3 indent

=item1 Key: C<style.indent>
=item1 Type: C<Str>
=item1 Default: C<"tab">

Whether to indent using tabs or spaces. Use C<"tab"> for tabbed indentation, or
C<"space"> for spaced indentation. If you're using space indentation, you may
want to set C<style.spaces> as well.

=head3 spaces

=item1 Key: C<style.spaces>
=item1 Type: C<Int>
=item1 Default: C<4>

The number of spaces to indent with, in case C<"space"> is used as
C<style.indent>. If C<"tab"> is set as the C<style.indent>, it merely specifies
the width that should be used to render a tab.

=head2 pause

Here you can specify your PAUSE credentials, which will be used whenever you
want to L<C<upload>|App::Assixt::Commands::Upload> a module distribution. For
security reasons, only the C<pause.id> will be allowed here.

=head3 id

=item1 Key: C<pause.id>
=item1 Type: C<Str>
=item1 Default: C<"">

Your PAUSE ID. If left empty, it will be prompted every time you use the
L<C<upload>|App::Assixt::Commands::Upload> subcommand. If you do not yet have a
PAUSE ID, you should L<request one
first|https://pause.perl.org/pause/query?ACTION=request_id>.

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Bootstrap::Config>

=end pod

# vim: ft=perl6 noet
