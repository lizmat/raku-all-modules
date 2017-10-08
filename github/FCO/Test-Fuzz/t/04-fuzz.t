use Test;

use lib "lib";

use-ok "Test::Fuzz";

{
	use Test::Fuzz;

	my sub test-func(Int $a, Str :$b) is fuzzed {}

	is &test-func.fuzzed, True;
}

done-testing
