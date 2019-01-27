#! /usr/bin/env false

use v6.c;

use Config;

class App::Assixt::Commands::Test
{
	method run(
		Config:D :$config,
	) {
		run(« prove -e "perl6 -Ilib" »).so
	}
}

=begin pod

=NAME    App::Assixt::Commands::Test
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt test

=head1 Description

Runs the module's tests. Currently, this is just a sugarcoated way to run
C<prove -e "perl6 -Ilib">.

=head1 Examples

    assixt test

=head1 See also

=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
