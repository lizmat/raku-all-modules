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

multi sub assixt(
	"new",
	Config:D :$config,
) is export {
	# Ask the user about some information on the module
	$config<runtime><name> //= ask("Module name");
	$config<runtime><author> //= ask("Your name", $config.get("new-module.author"));
	$config<runtime><email> //= ask("Your email address", $config.get("new-module.email"));
	$config<runtime><perl> //= ask("Perl 6 version", $config.get("new-module.perl"));
	$config<runtime><description> //= ask("Module description", "Nondescript");
	$config<runtime><license> //= ask("License key", $config.get("new-module.license"));

	# Create a directory name for the module
	my $dir-name = $config.get("new-module.dir-prefix") ~ $config<runtime><name>.subst("::", "-", :g);

	# Make sure it isn't already taken on the local system
	if (!$config<force> && $dir-name.IO.e && dir($dir-name)) {
		note "$dir-name is not empty!";
		return;
	}

	# Create the initial %meta
	my %meta = %(
		meta-version => 0,
		perl => "6.$config<runtime><perl>",
		name => $config<runtime><name>,
		description => $config<runtime><description>,
		license => $config<runtime><license>,
		authors => ("$config<runtime><author> <$config<runtime><email>>"),
		tags => (),
		version => "0.0.0",
		provides => %(),
		depends => (),
		resources => (),
	);

	# Create the module skeleton
	mkdir $dir-name unless $dir-name.IO.d;
	chdir $dir-name;
	mkdir "bin" unless $config<force> && "bin".IO.d;
	mkdir "lib" unless $config<force> && "lib".IO.d;
	mkdir "resources" unless $config<force> && "r".IO.d;
	mkdir "t" unless $config<force> && "t".IO.d;

	template("editorconfig", ".editorconfig", context => $config<style>, clobber => $config<force>);
	template("gitignore", ".gitignore", clobber => $config<force>) if $config<external><git> && !$config<runtime><no-git>;
	template("travis.yml", ".travis.yml", clobber => $config<force>) if $config<external><travis> && !$config<runtime><no-travis>;

	# Write some files
	put-meta(:%meta);

	say "Created new project folder at {".".IO.absolute}";
}
