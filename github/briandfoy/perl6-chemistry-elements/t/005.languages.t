use v6;
use Test;

constant package-name = 'Chemistry::Elements';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

can-ok $class, 'lang_str_to_column';

my @tests = (
	( 'pigLatin' ),
	( 'en', 'en_US', 'default' ),
	( 'en_UK' ),
	( 'de' ),
	( 'ru' ),
	);

for 0 .. @tests.end -> $index {
	my @list = @tests[$index].flat;
	for @list -> $item {
		is $class.lang_str_to_column( $item ), $index, "$item returns column $index";
		}

	};

done-testing;
