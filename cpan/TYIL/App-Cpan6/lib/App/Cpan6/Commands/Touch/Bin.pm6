#! /usr/bin/env false

use v6;

use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Touch::Bin;

multi sub MAIN("touch", "bin", Str $provide)
{
	my %meta = get-meta;
	my $path = "./bin".IO;

	$path = $path.add($provide);

	if ($path.e) {
		die "File already exists at {$path.absolute}";
	}

	mkdir $path.parent.absolute;

	# Create template
	my $template = qq:to/EOF/
#! /usr/bin/env perl6

use v{%meta<perl>};

sub MAIN
\{
	…
\}
EOF
;

	spurt($path.absolute, $template);

	# Update META6.json
	%meta<provides>{$provide} = $path.relative;

	put-meta(:%meta);

	# Inform the user of success
	say "Added $provide to {%meta<name>}";
}
