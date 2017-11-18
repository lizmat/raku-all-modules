#! /usr/bin/env false

use v6;

use App::Cpan6::Config;
use App::Cpan6::Input;
use App::Cpan6::Meta;
use Config;

unit module App::Cpan6::Commands::New;

multi sub MAIN("new", Str $name, Bool :$git = True) is export
{
	my Config $config = get-config;

	# Create a directory name for the module
	my $dir-name = $config.get("new-module.dir-prefix") ~ $name.subst("::", "-", :g);

	# Make sure it isn't already taken on the local system
	if ($dir-name.IO.e) {
		die "Directory named $dir-name already exists.";
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
		authors => ("$author <$email>"),
		tags => (),
		version => "0.0.0",
		provides => %(),
		depends => (),
	);

	# Create the module skeleton
	mkdir $dir-name;
	chdir $dir-name;
	mkdir "bin";
	mkdir "lib";
	mkdir "t";

my $editorconfig = q:to/EOF/
[*]
charset              = utf8
end_of_line          = lf
insert_final_newline = true
indent_style         = tab

[*.json]
indent_style = space
indent_size  = 2
EOF
;

	# Write some files
	put-meta(:%meta);

	if ($git) {
		my $gitignore = q:to/EOF/
# Perl 6 precompiled files
.precomp

# Editor files
*~     # emacs
.*.sw? # vim
EOF
		;

		spurt(".gitignore", $gitignore);

		run « git init »;
		run « git add . »;
		run « git commit -m "Initial commit" »;
	}

	say "Created new project folder at {$dir-name.IO.absolute}";
}

multi sub MAIN("new", Bool :$git = True) is export
{
	MAIN("new", ask("Name of the module"), :$git);
}
