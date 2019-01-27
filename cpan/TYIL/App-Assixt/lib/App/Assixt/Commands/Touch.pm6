#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;

unit class App::Assixt::Commands::Touch;

method run(*@args, Config:D :$config)
{
	my $type = @args.shift;
	my $formatted-type = $type.split("-", :g)».tclc.join();
	my $lib = "{$?CLASS.^name}::$formatted-type";

	err("debug.require", module => $lib, intent => $type) if $config<verbose>;

	try require ::($lib);

	if (::($lib) ~~ Failure) {
		err("error.subcommand", command => $type, docs => $?CLASS.^name);

		note ::($lib).Str if $config<verbose>;

		exit 2;
	}

	::($lib).run(|@args, :$config);
}

=begin pod

=NAME    App::Assixt::Commands::Touch
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt touch <type>

=head2 Types

=defn bin
Create a new runnable Perl 6 program. The filename will not contain an
extension, and the file itself will be stored in the C<bin> directory of your
module. Upon installation of your module, this file will become available in
the user's C<$PATH>.

=defn class
Create an empty class in the C<lib> directory.

=defn lib
Create an empty file in the C<lib> directory. This will not contain the
structure for a module, class or other regularly used constructs. Most often,
you will want to use a more specific type, such as C<bin>, C<class> or
C<module>.

=defn meta
Create a meta-module file. These are files that oftentimes do not contain any
Perl 6 code, but instead contain meta information. For more information about
the available meta files, read the documentation on
C<App::Assixt::Commands::Touch::Meta>.

=defn module
Create an empty module in the C<lib> directory.

=defn resource
Create an empty resource file in C<resources>.

=defn test
Create an empty test file in C<t>.

=head1 Description

Add a new file to the module. This will generate a skeleton file, and add it to
the module's C<META6.json>.

=head1 Examples

    assixt touch class Local::Test
    assixt touch unit Local::Test::Unit
    assixt touch resource local/resource.txt
    assixt touch test 01-use-ok

=head1 See also

=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
