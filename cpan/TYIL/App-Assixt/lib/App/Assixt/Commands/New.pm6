#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Dist::Helper::Meta;
use Dist::Helper::Template;
use Config;
use File::Directory::Tree;
use File::Which;

unit module App::Assixt::Commands::New;

multi sub MAIN(
	"new",
	Str:D :$name is copy = "",
	Str:D :$author is copy = "",
	Str:D :$email is copy = "",
	Str:D :$perl is copy = "",
	Str:D :$description is copy = "",
	Str:D :$license is copy = "",
	Bool:D :$no-git = False,
	Bool:D :$no-travis = False,
	Bool:D :$force = False,
	Bool:D :$no-user-config = False,
) is export {
	my Config $config = get-config(:$no-user-config);

	# Ask the user about some information on the module
	$name ||= ask("Module name");
	$author ||= ask("Your name", $config.get("new-module.author"));
	$email ||= ask("Your email address", $config.get("new-module.email"));
	$perl ||= ask("Perl 6 version", $config.get("new-module.perl"));
	$description ||= ask("Module description", "Nondescript");
	$license ||= ask("License key", $config.get("new-module.license"));

	# Create a directory name for the module
	my $dir-name = $config.get("new-module.dir-prefix") ~ $name.subst("::", "-", :g);

	# Make sure it isn't already taken on the local system
	if (!$force && $dir-name.IO.e && dir($dir-name)) {
		note "$dir-name is not empty!";
		return;
	}

	# Create the initial %meta
	my %meta = %(
		meta-version => 0,
		perl => "6.$perl",
		name => $name,
		description => $description,
		license => $license,
		authors => ("$author <$email>"),
		tags => (),
		version => "0.0.0",
		provides => %(),
		depends => (),
		resources => (),
	);

	# Create the module skeleton
	mkdir $dir-name unless $dir-name.IO.d;
	chdir $dir-name;
	mkdir "bin" unless $force && "bin".IO.d;
	mkdir "lib" unless $force && "lib".IO.d;
	mkdir "resources" unless $force && "r".IO.d;
	mkdir "t" unless $force && "t".IO.d;

	say template("editorconfig", ".editorconfig", context => $config<style>, clobber => $force);
	say template("gitignore", ".gitignore", clobber => $force) if $config<external><git> && !$no-git;
	say template("travis.yml", ".travis.yml", clobber => $force) if $config<external><travis> && !$no-travis;

	# Write some files
	put-meta(:%meta);

	say "Created new project folder at {".".IO.absolute}";
}
