#! /usr/bin/env false

use v6.c;

unit module App::Assixt;

=begin pod

=NAME    App::Assixt
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Description

C<App::Assixt> is a Perl 6 module to assist module developers in their efforts
to create new modules. It provides a number of helpful tools to achieve this,
through the C<assixt> program bundled in the module.

All other modules being referred to can be read using C<p6man>. For example, to
read more about the C<bump> command, you can read the documentation for it at
C<App::Assixt::Commands::Bump>, which you can open ith C<p6man>:

    p6man App::Assixt::Commands::Bump

=head1 Subcommands

C<assixt> allows for a number of subcommands, which all come with their own
documentation. You can read this documentation using C<p6man>, which is a
utility to read Perl 6 Pod of an installed module. Below is a list of available
subcommands, and a short description of their uses.

=head2 bootstrap

Documentation available at C<App::Assixt::Commands::Bootstrap>.

Functionality to boostrap C<assixt> itself, such as generating a configuration
file.

=head2 bump

Documentation available at C<App::Assixt::Commands::Bump>.

Bump the version number of the module.

=head2 clean

Documentation available at C<App::Assixt::Commands::Clean>.

Clean up a module, removing files not referenced in C<META6.json>, and removing
entries from C<META6.json> which don't appear in the live filesystem.

=head2 depend

Documentation available at C<App::Assixt::Commands::Depend>.

Add a dependency to a module.

=head2 dist

Documentation available at C<App::Assixt::Commands::Dist>.

Create a distribution tarball of a module.

=head2 new

Documentation available at C<App:Assixt::Commands::New>.

Create a new module.

=head2 push

Documentation available at C<App::Assixt::Commands::Push>.

Push a new release to L<PAUSE|https://pause.perl.org/pause/query>N<PAUSE is the
Perl Authors Upload Server, which is the backend for CPAN.>. This will perform a
C<bump>, C<dist> and C<upload> in this order.

=head2 test

Documentation available at C<App::Assixt::Commands::Test>.

Run the tests for a module.

=head2 touch

Documentation available at C<App::Assixt::Commands::Touch>.

Add a new file to a module.

=head2 undepend

Documentation available at C<App::Assixt::Commands::Undepend>.

Remove a dependency from a module.

=head2 upload

Documentation available at C<App::Assixt::Commands::Upload>.

Upload a distribution tarball to PAUSE.

=head1 Feedback and suggestions

If you have any feedback or suggestions on how to improve the module, do not
hesitate to open an issue on the L<GitLab
repository|https://gitlab.com/tyil/perl6-app-assixt/>.

=end pod

# vim: ft=perl6 noet
