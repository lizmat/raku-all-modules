use v6;
use Test;

plan 15;

constant package-name = 'Chemistry::Elements';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

my $method  = 'get_name_by_Z';
can-ok $class, $method;

my $callable = $class.^find_method( $method );

is
	$class."$method"(37), 'Rubidium',
	'Z=37 is Rubidium';

is
	$class."$method"(37, "en"), 'Rubidium',
	'Z=37 is Rubidium';

is
	$class."$method"(37, "de"), 'Rubidium',
	'Z=37 ist Rubidium';

is
	$class.$callable(1), 'Hydrogen',
	'Z=1 is Hydrogen';

is
	$class.$callable(1, "en"), 'Hydrogen',
	'Z=1 is Hydrogen';

is
	$class."$method"(1, "de"), 'Wasserstoff',
	'Z=1 is Wasserstoff';

lives-ok { for 1..118 -> $Z { $class."$method"($Z, "en") } },
	'Z is valid for 1 to 118';

lives-ok { $class."$method"("37", "en") }, 'Z is valid Str "37"';

# invalid because they are not in the numeric range
dies-ok { $class."$method"(119, "en") }, '119 is not a valid Z';
dies-ok { $class."$method"(999, "en") }, '999 is not a valid Z';

dies-ok { $class."$method"(37.3, "en") }, '37.3 is a not valid Z';


# invalid because they are not the right type of value
dies-ok { $class."$method"('100foo', "en") }, 'A convertible Str is a not valid Z';
dies-ok { $class."$method"('Some Str', "en") }, 'A Str is not a valid Z';

done-testing;
