#! /usr/bin/env false

use v6;

use App::Cpan6::Input;
use App::Cpan6::Meta;

unit module App::Cpan6::Commands::New;

multi sub MAIN("new", Str $module-name = "", Bool :$git = True) is export
{
	my Str $name = $module-name;

	# Ask for a module name if one was not supplied yet
	if ($name eq "") {
		$name = ask("Name of the module");
	}

	# Create a directory name for the module
	my $dir-name = "perl6-" ~ $name.subst("::", "-", :g);

	# Make sure it isn't already taken on the local system
	if ($dir-name.IO.e) {
		die "Directory named $dir-name already exists.";
	}

	# Ask the user about some information on the module
	my $author = ask("Your name");
	my $email = ask("Your email address");
	my $perl = ask("Perl 6 version", :default("c"));
	my $description = ask("Module description", :default("Nondescript"));
	my $license = ask("License key", :default("GPL-3.0"));

	# Create the initial %meta
	my %meta = %(
		meta-version => 1,
		perl => "6.$perl",
		name => $name,
		description => $description,
		authors => ("$author <$email>"),
		tags => (),
		version => "0.0.0",
		provides => (),
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
