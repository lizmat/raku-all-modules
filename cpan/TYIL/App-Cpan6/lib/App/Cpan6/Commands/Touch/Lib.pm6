#! /usr/bin/env false

use v6;

use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Touch::Lib;

multi sub MAIN("touch", "lib", Str $provide, Str :$type = "") is export
{
	my %meta = get-meta;
	my $path = "./lib".IO;

	# Deduce the path to create
	for $provide.split("::") {
		$path = $path.add($_);
	}

	$path = $path.extension("pm6", parts => 0);

	if ($path.e) {
		die "File already exists at {$path.absolute}";
	}

	# Create directories if needed
	mkdir $path.parent.absolute;

	# Create template
	my $template = qq:to/EOF/
#! /usr/bin/env false

use v{%meta<perl>};

EOF
;

	given $type {
		when "class" {
			$template ~= "class $provide " ~ '{ … }' ~ "\n";
		}
		when "unit" {
			$template ~= "unit module $provide;\n";
		}
	}

	spurt($path.absolute, $template);

	# Update META6.json
	%meta<provides>{$provide} = $path.relative;

	put-meta(:%meta);

	# Inform the user of success
	say "Added $provide to {%meta<name>}";
}

multi sub MAIN("touch", "class", Str $provide) is export
{
	MAIN("touch", "lib", $provide, type => "class");
}

multi sub MAIN("touch", "unit", Str $provide) is export
{
	MAIN("touch", "lib", $provide, type => "unit");
}
