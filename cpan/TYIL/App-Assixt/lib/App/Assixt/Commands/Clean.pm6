#! /usr/bin/env false

use v6.c;

use App::Assixt::Input;
use Config;
use Dist::Helper::Clean;
use Dist::Helper::Meta;

unit class App::Assixt::Commands::Clean;

multi method run (
	IO::Path:D $path,
	Config:D :$config,
) {
	# Clean up the META6.json
	unless ($config<runtime><no-meta>) {
		my %meta = clean-meta(
			$path,
			force => $config<force>,
			verbose => $config<verbose>,
		);

		put-meta(%meta, $path) if $config<force> || confirm("Save cleaned META6.json?");
	}

	# Clean up unreferenced files
	unless ($config<runtime><no-files>) {
		my @orphans = clean-files(
			$path,
			force => $config<force>,
			verbose => $config<verbose>,
		);

		for @orphans -> $orphan {
			unlink($orphan) if $config<force> || confirm("Really delete $orphan?");
		}
	}
}

multi method run (
	Str:D $path,
	Config:D :$config,
) {
	samewith($path.IO, :$config);
}

multi method run (
	Config:D :$config,
) {
	samewith($config<cwd>, :$config);
}

=begin pod

=NAME    App::Assixt::Commands::Clean
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt clean

=head1 Description

Clean up a module, removing all files not referenced from C<META6.json>, and
removing all references in C<META6.json> mapping to non-existing files.

=head1 Examples

    assixt clean

=head1 See also

=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
