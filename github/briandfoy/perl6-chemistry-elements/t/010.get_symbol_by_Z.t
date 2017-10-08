use v6;
use Test;

plan 11;

constant package-name = 'Chemistry::Elements';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

my $method  = 'get_symbol_by_Z';
can-ok $class, $method;

my $callable = $class.^find_method( $method );

is
	$class."$method"(82), 'Pb',
	'Z=82 is Pb (Lead)';

is
	$class.$callable(2), 'He',
	'Z=2 is He (Helium)';

lives-ok { for 1..118 -> $Z { $class."$method"($Z) } },
	'Z is valid for 1 to 118';

lives-ok { $class."$method"("37") }, 'Z is valid Str "37"';

# invalid because they are not in the numeric range
dies-ok { $class."$method"(119) }, '119 is not a valid Z';
dies-ok { $class."$method"(999) }, '999 is not a valid Z';

dies-ok { $class."$method"(37.3) }, '37.3 is a not valid Z';


# invalid because they are not the right type of value
dies-ok { $class."$method"('100foo') }, 'A convertible Str is a not valid Z';
dies-ok { $class."$method"('Some Str') }, 'A Str is not a valid Z';

done-testing;

