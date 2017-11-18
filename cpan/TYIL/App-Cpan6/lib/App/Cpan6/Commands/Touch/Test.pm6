#! /usr/bin/env false

use v6;

use App::Cpan6::Meta;

unit module App::Cpan6::Commands::Touch::Test;

multi sub MAIN("touch", "test", Str $test) is export
{
	my %meta = get-meta;
	my $path = "./t".IO;

	$path = $path.add($test);
	$path = $path.extension("t", parts => 0);

	if ($path.e) {
		die "File already exists at {$path.absolute}";
	}

	# Create directories if needed
	mkdir $path.parent.absolute;

	my $template = qq:to/EOF/
#! /usr/bin/env perl6

use v{%meta<perl>};

use Test;

ok True;

done-testing;

# vim: ft=perl6
EOF
;
	spurt($path.absolute, $template);

	# Inform the user of success
	say "Added test $test to {%meta<name>}";
}
