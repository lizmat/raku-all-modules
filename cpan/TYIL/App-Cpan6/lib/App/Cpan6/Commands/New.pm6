#! /usr/bin/env false

use v6;

use App::Cpan6::Config;
use App::Cpan6::Input;
use App::Cpan6::Meta;
use App::Cpan6::Template;
use Config;
use File::Directory::Tree;
use File::Which;

unit module App::Cpan6::Commands::New;

multi sub MAIN(
	"new",
	Str $name,
	Bool :$force = False,
	Bool :$no-git = True,
	Bool :$no-travis = True,
) is export {
	my Config $config = get-config;

	# Create a directory name for the module
	my $dir-name = $config.get("new-module.dir-prefix") ~ $name.subst("::", "-", :g);

	# Make sure it isn't already taken on the local system
	if (!$force && $dir-name.IO.e && dir($dir-name)) {
		note "$dir-name is not empty!";
		return;
	}

	# Ask the user about some information on the module
	my $author = ask("Your name", :default($config.get("new-module.author")));
	my $email = ask("Your email address", :default($config.get("new-module.email")));
	my $perl = ask("Perl 6 version", :default($config.get("new-module.perl")));
	my $description = ask("Module description", :default("Nondescript"));
	my $license = ask("License key", :default($config.get("new-module.license")));

	# Create the initial %meta
	my %meta = %(
		meta-version => 1,
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

	template("editorconfig", ".editorconfig", context => $config<style>);
	template("travis.yml", ".travis.yml") unless $config<external><travis> || $no-travis;

	# Write some files
	put-meta(:%meta);

	if ($config<externel><git> && !$no-git) {
		copy(%?RESOURCES<templates/gitignore>.absolute, ".gitignore", :!createonly);

		if (which("git")) {
			rmtree ".git" if ".git".IO.d;

			run « git init »;
			run « git add . »;
			run « git commit -m "Initial commit" »;
		}
	}

	say "Created new project folder at {".".IO.absolute}";
}

multi sub MAIN(
	"new",
	Bool :$force = False,
	Bool :$no-git = True,
	Bool :$no-travis = True,
) is export {
	MAIN("new", ask("Name of the module"), :$force, :$no-git, :$no-travis);
}
